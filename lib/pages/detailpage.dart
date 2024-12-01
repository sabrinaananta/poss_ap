import 'package:flutter/material.dart';
import 'package:posproject/LocalDb.dart';
import 'package:posproject/pages/CartPage.dart';

class DetailPage extends StatefulWidget {
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final LocalDatabase _localDatabase = LocalDatabase();
  late Future<List<Map<String, dynamic>>> _orderDetails;

  // Variabel untuk pilihan opsi
  String? _selectedSize;
  String? _selectedSweetness;
  String? _selectedIceCube;
  List<String> _selectedToppings = [];

  // Variabel quantity
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _orderDetails = _localDatabase.fetchOrderDetails();
  }

  // Fungsi untuk memeriksa apakah semua opsi wajib sudah dipilih
  bool _areMandatoryOptionsSelected() {
    return _selectedSize != null && _selectedSweetness != null && _selectedIceCube != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // Mengatur background menjadi biru
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _orderDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak ada data tersedia.'));
          }

          final orderDetails = snapshot.data!;

          // Urutan penempatan kategori
          final priorityOrder = ['Size', 'Sweetness', 'Ice Cube', 'Topping'];

          // Tampilannya sesuai priority ordernya
          orderDetails.sort((a, b) {
            final aIndex = priorityOrder.indexOf(a['category']);
            final bIndex = priorityOrder.indexOf(b['category']);
            return aIndex.compareTo(bIndex);
          });

          // Dikelompokkan untuk menghindari perulangan banyak
          final groupedCategories = groupCategories(orderDetails);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: groupedCategories.length,
                  itemBuilder: (context, index) {
                    final category = groupedCategories[index];
                    final categoryName = category['category'];
                    final choices = category['choices'];
                    final isMandatory = category['mandatory'] ?? false;

                    // Label untuk wajib dan opsionalnya
                    String label = isMandatory ? "Wajib" : "Optional";

                    // Fungsi buildCategory untuk menghindari perulangan
                    return _buildCategory(categoryName, choices, label);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity section
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                if (_quantity > 1) {
                                  _quantity--;
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '$_quantity',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(width: 10),
                        // Tombol +
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    // Tombol harga dengan warna yang berubah berdasarkan status pilihan
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _areMandatoryOptionsSelected()
                            ? Colors.blue
                            : Colors.grey, // Ganti warna tombol berdasarkan status
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _areMandatoryOptionsSelected()
                          ? () {
                              // Penempatan fungsi totalnya nanti
                            }
                          : null, // Tombol tidak bisa ditekan jika belum lengkap
                      child: Text(
                        'Rp 24.000', // Contoh harga
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Fungsi untuk mengelompokkan kategori
  List<Map<String, dynamic>> groupCategories(List<Map<String, dynamic>> orderDetails) {
    Set<String> processedCategories = Set();
    List<Map<String, dynamic>> groupedCategories = [];

    for (var category in orderDetails) {
      final categoryName = category['category'];

      // Jika kategori belum diproses, tambahkan ke dalam daftar
      if (!processedCategories.contains(categoryName)) {
        processedCategories.add(categoryName);
        groupedCategories.add(category);
      }
    }
    return groupedCategories;
  }

  // Fungsi untuk membangun kategori dengan radio dan checkbox
  Widget _buildCategory(String categoryName, List choices, String label) {
    bool isRadioCategory = categoryName == "Size" ||
        categoryName == "Sweetness" ||
        categoryName == "Ice Cube";

    if (isRadioCategory) {
      return _buildRadioCategory(categoryName, choices, label);
    } else if (categoryName == "Topping") {
      return _buildCheckboxCategory(categoryName, choices, label);
    }

    return Container(); // Return jika tidak sesuai
  }

  // Fungsi untuk membangun kategori size, sweetness, icecube
  Widget _buildRadioCategory(String categoryName, List choices, String label) {
    String? selectedValue;

    if (categoryName == "Size") {
      selectedValue = _selectedSize;
    } else if (categoryName == "Sweetness") {
      selectedValue = _selectedSweetness;
    } else if (categoryName == "Ice Cube") {
      selectedValue = _selectedIceCube;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$categoryName",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
               Text(
      label == "Optional" ? "Wajib" : label,  
      style: TextStyle(fontSize: 11, color: Colors.black38, fontFamily: 'Poppins'),
    ),
            ],
          ),
          Column(
            children: choices.map<Widget>((choice) {
              return RadioListTile<String>(
                title: Text(choice['name'], style: TextStyle(fontFamily: 'Poppins')),
                subtitle: choice['additional_price'] != null
                    ? Text('Rp ${choice['additional_price']}', style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                    ))
                    : null,
                value: choice['name'],
                groupValue: selectedValue,
                controlAffinity: ListTileControlAffinity.trailing,
                onChanged: (value) {
                  setState(() {
                    if (categoryName == "Size") {
                      _selectedSize = value;
                    } else if (categoryName == "Sweetness") {
                      _selectedSweetness = value;
                    } else if (categoryName == "Ice Cube") {
                      _selectedIceCube = value;
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk kategori topping dengan checkbox
  Widget _buildCheckboxCategory(String categoryName, List choices, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$categoryName",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.black38, fontFamily: 'Poppins'),
              ),
            ],
          ),
          Column(
            children: choices.map<Widget>((choice) {
              return CheckboxListTile(
                title: Text(choice['name'], style: TextStyle(fontFamily: 'Poppins')),
                subtitle: choice['additional_price'] != null
                    ? Text('Rp ${choice['additional_price']}', style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                    ))
                    : null,
                value: _selectedToppings.contains(choice['name']),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedToppings.add(choice['name']);
                    } else {
                      _selectedToppings.remove(choice['name']);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
