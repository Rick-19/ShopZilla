import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _iamgeFocusNode = FocusNode();
  final _imageEditingController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Product _editedProduct = Product(
    id: null,
    description: '',
    imageUrl: '',
    title: '',
    price: 0,
  );
  var isInit = true;
  var initValues = {
    'description': '',
    'imageUrl': '',
    'title': '',
    'price': '',
  };
  var isLoading = false;

  @override
  void initState() {
    _iamgeFocusNode.addListener(_updateImageURL);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        initValues = {
          'title': _editedProduct.title ?? '',
          'description': _editedProduct.description ?? '',
          'imageUrl': '',
          'price': _editedProduct.price != null
              ? _editedProduct.price.toString()
              : '0',
        };
        _imageEditingController.text = _editedProduct.imageUrl ?? '';
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageURL() {
    if (!_iamgeFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveform() async {
    final isValid = _form.currentState?.validate();
    if (isValid == null) return;
    if (!_imageEditingController.text.startsWith('http') &&
        !_imageEditingController.text.startsWith('https')) return;
    _form.currentState?.save();
    setState(() {
      isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id!, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProducts(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An Error Ocurred'),
                  content: Text('Something went wrong!'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Okay'))
                  ],
                ));
      }
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _iamgeFocusNode.removeListener(_updateImageURL);
    _imageEditingController.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveform,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      validator: (value) {
                        if (value!.isEmpty)
                          return 'Please Provide a Value';
                        else
                          return null;
                      },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          title: newValue,
                          price: _editedProduct.price,
                        );
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                    ),
                    TextFormField(
                      initialValue: initValues['price'],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      validator: (value) {
                        if (double.parse(value!) < 0)
                          return 'Value can\'t be Negative';
                        else if (double.parse(value) == 0)
                          return 'Value can\'t be zero';
                        else if (double.tryParse(value) == null)
                          return 'Enter a valid number';
                        else
                          return null;
                      },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          title: _editedProduct.title,
                          price: double.parse(newValue!),
                        );
                      },
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      focusNode: _priceFocusNode,
                    ),
                    TextFormField(
                      initialValue: initValues['description'],
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) {
                        if (value!.isEmpty)
                          return 'Please Enter a Description';
                        else if (value.length < 10)
                          return 'Description is Too Short';
                        else
                          return null;
                      },
                      onSaved: (newValue) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          description: newValue,
                          imageUrl: _editedProduct.imageUrl,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                        );
                      },
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(right: 10, top: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageEditingController.text.isEmpty
                              ? Text(
                                  'Enter URL',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              : FittedBox(
                                  child: Image.network(
                                      _imageEditingController.text),
                                  fit: BoxFit.contain,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              label: Text('Image URL'),
                            ),
                            textInputAction: TextInputAction.done,
                            controller: _imageEditingController,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (value) {
                              _saveform();
                            },
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Enter a Url';
                              else if (!value.startsWith('http') &&
                                  !value.startsWith('https'))
                                return 'Url is not valid';
                              else
                                return null;
                            },
                            focusNode: _iamgeFocusNode,
                            onSaved: (newValue) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavourite: _editedProduct.isFavourite,
                                description: _editedProduct.description,
                                imageUrl: newValue,
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
