import 'package:project/helper/utils/generalImports.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class ProductDescriptionView extends StatelessWidget {
  final ProductData product;
  final BuildContext context;

  const ProductDescriptionView(
      {Key? key, required this.context, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuillHtmlEditor(
      text: product.description,
      hintText: getTranslatedValue(context, "description_goes_here"),
      isEnabled: false,
      ensureVisible: false,
      minHeight: 10,
      autoFocus: false,
      textStyle: TextStyle(color: ColorsRes.mainTextColor),
      hintTextStyle: TextStyle(color: ColorsRes.subTitleMainTextColor),
      hintTextAlign: TextAlign.start,
      padding: const EdgeInsets.only(left: 10, top: 10),
      hintTextPadding: const EdgeInsets.only(left: 20),
      backgroundColor: Theme.of(context).cardColor,
      inputAction: InputAction.newline,
      loadingBuilder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: ColorsRes.appColor,
          ),
        );
      },
      controller: QuillEditorController(),
    );
  }
}
