import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class DeliveryBoyBankInformationWidget extends StatefulWidget {
  final String from;
  final Map<String, String> personalData;

  const DeliveryBoyBankInformationWidget(
      {Key? key, required this.personalData, required this.from})
      : super(key: key);

  @override
  State<DeliveryBoyBankInformationWidget> createState() =>
      DeliveryBoyBankInformationWidgetState();
}

class DeliveryBoyBankInformationWidgetState
    extends State<DeliveryBoyBankInformationWidget> {
  late TextEditingController edtBankName,
      edtAccountNumber,
      edtIFSCCode,
      edtAccountName;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    edtBankName = TextEditingController(
      text: widget.personalData[ApiAndParams.bank_name],
    );
    edtAccountNumber = TextEditingController(
      text: widget.personalData[ApiAndParams.bank_account_number],
    );
    edtIFSCCode = TextEditingController(
      text: widget.personalData[ApiAndParams.ifsc_code],
    );
    edtAccountName = TextEditingController(
      text: widget.personalData[ApiAndParams.account_name],
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      shape: DesignConfig.setRoundedBorder(7),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Constant.paddingOrMargin10,
          vertical: Constant.paddingOrMargin10,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextLabel(
                jsonKey: "bank_information",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: ColorsRes.mainTextColor,
                ),
              ),
              getSizedBox(height: 10),
              Divider(
                  height: 1,
                  color: ColorsRes.grey.withOpacity(0.5),
                  thickness: 1),
              getSizedBox(height: 10),
              editBoxWidget(
                context: context,
                edtController: edtBankName,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "bank_name"),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtAccountNumber,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "account_number"),
                inputType: TextInputType.numberWithOptions(
                    signed: false, decimal: true),
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtIFSCCode,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "ifsc_code"),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtAccountName,
                validationFunction: emptyValidation,
                label: getTranslatedValue(context, "account_name"),
                inputType: TextInputType.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
