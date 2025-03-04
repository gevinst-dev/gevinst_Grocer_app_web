<?php

namespace App\Http\Controllers\API;

use App\Helpers\CommonHelper;
use App\Http\Controllers\Controller;
use App\Jobs\SendEmailJob;
use App\Models\Admin;
use App\Models\DeliveryBoy;
use App\Models\FundTransfer;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\OrderStatus;
use App\Models\OrderStatusList;
use App\Models\Role;
use App\Models\Seller;
use App\Models\Setting;
use App\Models\Transaction;
use App\Models\User;
use App\Models\DeliveryBoyTransaction;
use App\Notifications\OrderNotification;
use Carbon\Carbon;
use Illuminate\Http\Request;
use DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class OrdersApiController extends Controller
{
    public function getOrders(Request $request){
        $limit = $request->input('per_page', 10); // Default items per page
        $offset = (($request->input('page', 0))-1)*$limit; // Default page
        $search = $request->input('search', ''); // Filter query

        $sellers = Seller::where('status',1)->orderBy('id','DESC')->get()->toArray();

        $startDate = Carbon::parse($request->input('startDate'))->startOfDay();
        $endDate = Carbon::parse($request->input('endDate'))->endOfDay();

        $startDeliveryDate = Carbon::parse($request->input('startDeliveryDate'))->startOfDay();
        $endDeliveryDate = Carbon::parse($request->input('endDeliveryDate'))->endOfDay();

        $orders = Order::select(
            'orders.id',
            'orders.mobile',
            'orders.total',
            'orders.delivery_charge',
            'orders.wallet_balance',
            'orders.final_total',
            'orders.payment_method',
            'orders.delivery_time',
            'sellers.name as seller_name',
            'users.name as user_name'
        )
        ->leftJoin('users', 'orders.user_id', '=', 'users.id')
        ->leftJoin('order_items', 'orders.id', '=', 'order_items.order_id')  // Join the order_items table
        ->leftJoin('sellers', 'order_items.seller_id', '=', 'sellers.id');   // Now join sellers table
            
        if(isset($request->startDate) && $request->startDate != "" && isset($request->endDate) && $request->endDate != ""){
            $orders = $orders->whereBetween('order_items.created_at', [$startDate, $endDate]);
        }

        if(isset($request->startDeliveryDate) && $request->startDeliveryDate != "" && isset($request->endDeliveryDate) && $request->endDeliveryDate != ""){
            // Convert start and end dates from request to Y-m-d format
            $startDeliveryDate = date('Y-m-d', strtotime($request->startDeliveryDate));
            $endDeliveryDate = date('Y-m-d', strtotime($request->endDeliveryDate));
        
            // Define a callback function to extract and format the delivery_time date
            $orders = $orders->where(function($query) use ($startDeliveryDate, $endDeliveryDate) {
                $query->whereRaw("STR_TO_DATE(SUBSTRING_INDEX(orders.delivery_time, ' ', 1), '%d-%m-%Y') BETWEEN ? AND ?", [$startDeliveryDate, $endDeliveryDate]);
            });
        }

        if(isset($request->seller) && $request->seller != ""){
            $orders = $orders->where('order_items.seller_id', $request->seller);
        }
        if(isset($request->status) && $request->status != ""){
            $orders = $orders->where('orders.active_status', $request->status);
        }
        
        // Apply filter to all columns in all joined tables
        if ($search) {
            $columns = [
                'orders.payment_method', 'orders.id', 'delivery_boys.name','orders.delivery_charge','orders.wallet_balance', 'orders.final_total','orders.total','orders.delivery_time','sellers.name',
                'users.name', 'order_items.active_status', 'products.name'
                // Add more columns as needed
            ];
            
            $orders = $orders->where(function($query) use ($search, $columns) {
                foreach ($columns as $column) {
                    $query->orWhere($column, 'like', "%{$search}%");
                }
            });
        }
        $orders = $orders->orderBy('orders.id', 'DESC')->groupBy('orders.id');

        $orders_total = $orders->get()->count();
        $orders = $orders->skip($offset)->take($limit)->get();

        $item_limit = $request->input('item_per_page', 10); // Default items per page
        $item_offset = (($request->input('item_page', 0))-1)*$item_limit; // Default page
        $data = array(
            "sellers" => $sellers,
            "orders" => $orders,
            "orders_total" => $orders_total
        );
        return CommonHelper::responseWithData($data);
    }

    public function view($id){
        /*$order = Order::select('orders.*','orders.id as order_id','orders.created_at as created_at','users.*','users.name as user_name','users.email as user_email'
             ,'users.email as user_email','users.mobile as user_mobile','address.*', 'sellers.*', 'sellers.name as seller_name', 'delivery_boys.name as delivery_boy_name',
            'order_items.id as order_item_id','os.status as active_status', 'cities.id as city_id', 'cities.name as city_name')
            ->leftJoin('order_items', 'order_items.order_id', '=', 'orders.id')
            ->leftJoin('users', 'orders.user_id', '=', 'users.id')
            ->leftJoin('user_addresses as address', 'orders.address_id', '=', 'address.id')
            ->leftJoin('cities', 'address.city_id', '=', 'cities.id')
            ->leftJoin('product_variants', 'order_items.product_variant_id', '=', 'product_variants.id')
            ->leftJoin('products', 'product_variants.product_id', '=', 'products.id')
            ->leftJoin('delivery_boys', 'orders.delivery_boy_id', '=', 'delivery_boys.id')
            ->leftJoin('sellers', 'order_items.seller_id', '=', 'sellers.id')
            ->leftJoin('order_status_lists as os', 'orders.active_status', '=', 'os.id')
            ->where('orders.id','=',$id)
            ->groupBy('orders.id')
            ->first();

        $order_items = Order::select('order_items.*','orders.mobile','orders.total' ,'orders.delivery_charge','orders.discount','orders.promo_code',
            'orders.promo_discount','orders.wallet_balance','orders.final_total','orders.payment_method','orders.address','orders.delivery_time',
            'users.name as user_name','order_items.status as order_status','sellers.name as seller_name','products.id as product_id', 'os.status as active_status')
            ->leftJoin('order_items', 'order_items.order_id', '=', 'orders.id')
            ->leftJoin('users', 'orders.user_id', '=', 'users.id')
            ->leftJoin('product_variants', 'order_items.product_variant_id', '=', 'product_variants.id')
            ->leftJoin('products', 'product_variants.product_id', '=', 'products.id')
            ->leftJoin('sellers', 'order_items.seller_id', '=', 'sellers.id')
            ->leftJoin('order_status_lists as os', 'order_items.active_status', '=', 'os.id')
            ->where('orders.id','=',$id)
            ->orderBy('order_items.id','DESC')
            ->get();*/
        $data = CommonHelper::getOrderDetails($id);
        if(!$data["order"]){
            return CommonHelper::responseError("Order Not found!");
        }
      //  dd($data["order"]->city_id);
        $deliveryBoys = DeliveryBoy::select('id','name')->where('city_id',$data["order"]->city_id)->where('status',1)->get();
       
        $data["deliveryBoys"] = $deliveryBoys;
        return CommonHelper::responseWithData($data);
    }


    public function generateOrderInvoice(Request $request){
        $data = CommonHelper::getOrderDetails($request->order_id);
        if(!$data["order"]){
            return CommonHelper::responseError("Order Not found!");
        }
        $invoice = CommonHelper::generateOrderInvoice($data);
        return CommonHelper::responseWithData($invoice);
    }
    public function downloadOrderInvoice(Request $request){
        return CommonHelper::downloadOrderInvoice($request->order_id);
    }

    public function delete(Request $request){
        if(isset($request->id)){
            $order = Order::find($request->id);
            if($order){
                $order->delete();
                return CommonHelper::responseSuccess("Order Deleted Successfully!");
            }else{
                return CommonHelper::responseSuccess("Order Already Deleted!");
            }
        }
    }

    public function deleteItem(Request $request){
        if(isset($request->id)){
            $orderItem = OrderItem::find($request->id);
            if($orderItem){
                $orderItem->delete();
                return CommonHelper::responseSuccess("Order Item Deleted Successfully!");
            }else{
                return CommonHelper::responseSuccess("Order Item Already Deleted!");
            }
        }
    }

    public function getWeeklySales(){
        $year = date("Y");
        $curdate = date('Y-m-d');
        $orders = Order::select(DB::raw('ROUND(SUM(final_total), 2) AS total_sale'), DB::raw('DATE(created_at) AS order_date'))
        ->where(DB::raw('YEAR(created_at)'),'=', $year)
        ->where(DB::raw('DATE(created_at)'),'<=', $curdate);

        $orders = $orders->groupBy(DB::raw('DATE(created_at)'))
            ->orderBy(DB::raw('DATE(created_at)'),'DESC')
            ->limit(7)->get();
        return CommonHelper::responseWithData($orders);
    }

    public function updateStatus(Request $request){
        $validator = Validator::make($request->all(),[
            'order_id' => 'required',
            'status_id' => 'required',
        ], [
            'order_id.required' => 'The Order id field is required.',
            'status_id.required' => 'The status field is required.',
        ]);
        if ($validator->fails()) {
            return CommonHelper::responseError($validator->errors()->first());
        }
        $order = Order::find($request->order_id);
        if(empty($order)){
            return CommonHelper::responseError("Order Not found!");
        }
        $selectedStatus = OrderStatusList::where('id',$request->status_id)->value('status');
        
        if($order->active_status == $request->status_id){
            return CommonHelper::responseError("This Order is already ".$selectedStatus."!");
        }

        if($order->active_status == 6 && $request->status_id < 6){
            return CommonHelper::responseError("This Order is Delivered");
        }

        if($order->active_status == OrderStatusList::$paymentPending){
            return CommonHelper::responseError("Payment is pending. Without payment order can not receive");
        }

        if($order->active_status == OrderStatusList::$returned || $order->active_status == OrderStatusList::$cancelled){
            return CommonHelper::responseError("Order is Cancelled OR Returned.");
        }

        if(auth()->user()->role_id != Role::$roleSuperAdmin ){
            if($order->active_status > $request->status_id){
                return CommonHelper::responseError("You can not update this order status to ".$selectedStatus."!");
            }
        }

        \Illuminate\Support\Facades\DB::beginTransaction();
        try {
           
            if($order->active_status != $request->status_id){
                
                if(isset($request->delivery_boy_id) && $request->delivery_boy_id != "" && $request->delivery_boy_id != 0){
                   
                    // Delivery Boy cash collection add and cash_received update with update balance of delivery boy start
                    if($request->status_id == OrderStatusList::$delivered) {
                        
                        $deliveryBoy = DeliveryBoy::find($request->delivery_boy_id);

                        $deliveryBoy->balance = floatval($deliveryBoy->balance) + floatval($order->delivery_boy_bonus_amount);
                        
                        CommonHelper::addFundTransfers($deliveryBoy->id, $order->delivery_boy_bonus_amount, FundTransfer::$typeCredit);

                        if ($order->payment_method == DeliveryBoyTransaction::$paymentTypeCod) {

                            $transactionData = array();
                            $transactionData['user_id'] = $order->user_id;
                            $transactionData['order_id'] = $order->id;
                            $transactionData['delivery_boy_id'] = $deliveryBoy->id;
                            $transactionData['type'] = $order->payment_method;
                            $transactionData['amount'] = $order->final_total;
                            $transactionData['status'] = Transaction::$statusSuccess;;
                            $transactionData['message'] = "Delivery boy ".OrderStatusList::$orderDelivered." this order. Order payment method was ".Transaction::$paymentTypeCod;
                            $transactionData['transaction_date'] = date('Y-m-d H:i:s');
                            $transaction = DeliveryBoyTransaction::create($transactionData);

                            $order->transaction_id = $transaction->id ?? 0;

                            $deliveryBoy->cash_received = floatval($deliveryBoy->cash_received) + floatval($order->final_total);
                        }

                        $deliveryBoy->save();
                    }
                    // Delivery Boy cash collection add and cash_received update with update balance of delivery boy end

                    $order->delivery_boy_id = $request->delivery_boy_id;
                }

                $order->active_status = $request->status_id;
                $order->save();

                $excludedStatuses = [OrderStatusList::$cancelled, OrderStatusList::$returned];

                // Update the order items
                $query = OrderItem::where("order_id", $request->order_id)
                    ->whereNotIn("active_status", $excludedStatuses)
                    ->update(['active_status' => $request->status_id]);

                $orderStatus = array();
                $orderStatus["order_id"] = $request->order_id; 
                $orderStatus['order_item_id'] = 0;
                $orderStatus["status"] = $request->status_id;
                $orderStatus["created_by"] = auth()->user()->id;
                $orderStatus["user_type"] = auth()->user()->role_id;
                CommonHelper::setOrderStatus($orderStatus);
            }else{
                $status = OrderStatusList::find($request->status_id);
                return CommonHelper::responseError("Status is already ".$status->status);
            }
            \Illuminate\Support\Facades\DB::commit();
        } catch (\Exception $e) {
            Log::info("Error : ".$e->getMessage());
            \Illuminate\Support\Facades\DB::rollBack();
            throw $e;
            return CommonHelper::responseError("Something Went Wrong!");
        }

        $order = Order::with('items')->where("id",$request->order_id)->first();

        if(!empty($order)){

            //CommonHelper::sendMailOrderStatus($order);
            log::info("order",[$order]);

            try {
                dispatch(function () use ($order, $request) {
                    CommonHelper::sendNotificationOrderStatus($order);
                    $admins = Admin::get();
                  
                    foreach ($admins as $admin) {
                        $admin->notify(new OrderNotification($order->id,(string)$request->status_id));
                    }
                })->afterResponse();
            } catch (\Exception $e) {
        
            }

            try {
                //self::sendMailOrderStatus($order);
                dispatch(new SendEmailJob($order))->afterResponse();
            }catch ( \Exception $e){
                Log::error("Update order status by delivery boy Send mail error :",[$e->getMessage()] );
            }
            //Order Status SMS
            try {
                CommonHelper::sendSmsOrderStatus($order, $order->active_status);
            }catch ( \Exception $e){
                Log::error("Update order status by delivery boy Send SMS error :",[$e->getMessage()] );
            }
        }
       

        return CommonHelper::responseSuccess("Order Updated Successfully!");
    }

    public function assignDeliveryBoy(Request $request){
        $validator = Validator::make($request->all(),[
            'order_id' => 'required',
            'delivery_boy_id' => 'required',
        ], [
            'order_id.required' => 'The Order id field is required.',
            'delivery_boy_id.required' => 'The delivery boy field is required.',
        ]);

        if ($validator->fails()) {
            return CommonHelper::responseError($validator->errors()->first());
        }

        $deliveryBoy = DeliveryBoy::find($request->delivery_boy_id);
        if(empty($deliveryBoy)) {
            return CommonHelper::responseSuccess("Delivery Boy Not Found!");
        }
        $order = Order::find($request->order_id);

        if($order) {
            if($order->delivery_boy_id == $request->delivery_boy_id){
                return CommonHelper::responseError("This delivery boy already assign!");
            }
            if($order->active_status == OrderStatusList::$paymentPending){
                return CommonHelper::responseError("Payment is pending. Without payment order can not receive");
            }

            $final_total = floatval($order->final_total);

            $bonus_type = $deliveryBoy->bonus_type;
            $bonus_details['final_total'] = $final_total;
            $bonus_details['bonus_type'] = $bonus_type;
            $bonus_amount = 0;
            if($bonus_type == DeliveryBoy::$bonusCommission){

                $bonus_percentage = floatval($deliveryBoy->bonus_percentage);
                $bonus_min_amount = floatval($deliveryBoy->bonus_min_amount);
                $bonus_max_amount = floatval($deliveryBoy->bonus_max_amount);

                $bonus_amount = floatval( ($final_total *  $bonus_percentage)/100);

                if($bonus_amount < $bonus_min_amount && $bonus_min_amount != 0){
                    $bonus_amount = $bonus_min_amount;
                }

                if($bonus_amount > $bonus_max_amount && $bonus_max_amount != 0){
                    $bonus_amount = $bonus_max_amount;
                }

                $bonus_details['bonus_type_name'] = DeliveryBoy::$commission;
                $bonus_details['bonus_percentage'] = $bonus_percentage;
                $bonus_details['bonus_min_amount'] = $bonus_min_amount;
                $bonus_details['bonus_max_amount'] = $bonus_max_amount;
                $bonus_details['bonus_amount'] = $bonus_amount;
            }else{
                $bonus_details['bonus_type_name'] = DeliveryBoy::$fixed;
            }
            $bonus_details['bonus_amount'] = $bonus_amount;

            $order->delivery_boy_bonus_details = $bonus_details;
            $order->delivery_boy_bonus_amount = $bonus_amount;

            $order->delivery_boy_id = $request->delivery_boy_id;
            $order->save();

            try {
                CommonHelper::sendMailOrderStatus($order, true);
                CommonHelper::sendNotificationOrderAssignDeliveryBoy($order);
            }catch ( \Exception $e){
                Log::error("Delivery boy assigned on order Send mail error :",[$e->getMessage()] );
            }

            return CommonHelper::responseSuccess("Delivery boy assigned Successfully for this order!");
        }else{
            return CommonHelper::responseError("Order Not found!");
        }

    }

    public function updateItemsStatus(Request $request){
        $validator = Validator::make($request->all(),[
            'ids' => 'required',
            'status_id' => 'required',
        ], [
            'ids.required' => 'The Item id field is required.',
            'status_id.required' => 'The status field is required.',
        ]);
        if ($validator->fails()) {
            return CommonHelper::responseError($validator->errors()->first());
        }
        $ids = explode(",",$request->ids);
        foreach ($ids as $key => $id){
            $orderItem = OrderItem::find($id);
            $orderItem->active_status = $request->status_id;
            $orderItem->save();

            $orderStatus = array();
            $orderStatus["order_id"] = $orderItem->order_id;
            $orderStatus["order_item_id"] = $id;
            $orderStatus["status"] = $request->status_id;
            $orderStatus["created_by"] = auth()->user()->id;
            $orderStatus["user_type"] = auth()->user()->role_id;
            CommonHelper::setOrderStatus($orderStatus);
        }
        return CommonHelper::responseSuccess("Order Updated Successfully!");
    }

}
