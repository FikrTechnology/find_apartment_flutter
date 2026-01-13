import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/image_picker_util.dart';
import '../bloc/property_bloc.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({Key? key}) : super(key: key);

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _propertyNameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;

  File? _selectedImage;
  String? _selectedImageName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _propertyNameController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Foto'),
          content: const Text('Ambil foto dari galeri atau kamera?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
              child: const Text('Galeri'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
              child: const Text('Kamera'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final result = await ImagePickerUtil.pickImageFromGallery();
      if (result != null) {
        setState(() {
          _selectedImage = result.$1;
          _selectedImageName = result.$2;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memilih foto: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final result = await ImagePickerUtil.pickImageFromCamera();
      if (result != null) {
        setState(() {
          _selectedImage = result.$1;
          _selectedImageName = result.$2;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menangkap foto: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih foto properti')),
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);

      // Validate image file exists before conversion
      final imageExists = await _selectedImage!.exists().catchError(
        (e) {
          print('Error checking image file: $e');
          return false;
        },
      );

      if (!imageExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File foto tidak dapat diakses')),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      final imageBase64 = await ImagePickerUtil.convertImageToBase64(_selectedImage!).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Timeout converting image to base64');
          return null;
        },
      );
      
      if (imageBase64 == null || imageBase64.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengkonversi foto ke Base64')),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      if (mounted) {
        context.read<PropertyBloc>().add(
          AddPropertyEvent(
            propertyName: _propertyNameController.text.trim(),
            price: _priceController.text.trim(),
            description: _descriptionController.text.trim(),
            fullAddress: _addressController.text.trim(),
            imageBase64: imageBase64,
            imageName: _selectedImageName ?? 'image.jpg',
          ),
        );
      }
    } catch (e) {
      print('Error in _submitForm: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error mengupload foto: $e')),
        );
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyBloc, PropertyState>(
      listener: (context, state) {
        if (state is PropertySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.pop();
            }
          });
        } else if (state is PropertyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isSubmitting = false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tambah Properti'),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Image Section
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: _selectedImage != null
                          ? Stack(
                              children: [
                                Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _selectedImage = null;
                                          _selectedImageName = null;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : GestureDetector(
                              onTap: _isSubmitting ? null : _showImageSourceDialog,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Pilih Foto Properti',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tekan untuk memilih dari galeri atau ambil foto',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey.shade500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),

                    // Property Name Field
                    Text(
                      'Nama Properti',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _propertyNameController,
                      enabled: !_isSubmitting,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Apartemen Mewah di Pusat Kota',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama properti tidak boleh kosong';
                        }
                        if (value.length < 5) {
                          return 'Nama properti minimal 5 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Price Field
                    Text(
                      'Harga',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 500000000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        prefixText: 'Rp ',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Harga harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !_isSubmitting,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Jelaskan fitur dan keunggulan properti...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        if (value.length < 20) {
                          return 'Deskripsi minimal 20 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Address Field
                    Text(
                      'Alamat Lengkap',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      enabled: !_isSubmitting,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Jl. Merdeka No. 123, Jakarta Pusat, DKI Jakarta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        if (value.length < 10) {
                          return 'Alamat terlalu singkat';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: state is PropertyLoading || _isSubmitting
                          ? FilledButton(
                              onPressed: null,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Mengirim...'),
                                ],
                              ),
                            )
                          : FilledButton(
                              onPressed: _submitForm,
                              child: const Text('Posting Properti'),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
