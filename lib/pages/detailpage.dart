import 'package:flutter/material.dart';
import 'package:posproject/LocalDb.dart'; // Import the LocalDb file

class DetailPage extends StatefulWidget {
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final LocalDatabase _localDatabase = LocalDatabase();
  late Future<List<Map<String, dynamic>>> _orderDetails;

  // Variables to hold the selected values
  String? _selectedSize;
  String? _selectedSweetness;
  String? _selectedIceCube;
  List<String> _selectedToppings = [];

  @override
  void initState() {
    super.initState();
    _orderDetails = _localDatabase.fetchOrderDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Detail'),
  centerTitle: true,
  actions: [
    IconButton(
      icon: Icon(Icons.shopping_cart),
      onPressed: () {
        
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

          // Urutan prioritas kategori
          final priorityOrder = ['Size', 'Sweetness', 'Ice Cube', 'Topping'];

          // Sort kategori berdasarkan urutan prioritas
          orderDetails.sort((a, b) {
            final aIndex = priorityOrder.indexOf(a['category']);
            final bIndex = priorityOrder.indexOf(b['category']);
            return aIndex.compareTo(bIndex);
          });

          // Group categories by name to avoid repeating
          final groupedCategories = groupCategories(orderDetails);

          return ListView.builder(
            itemCount: groupedCategories.length,
            itemBuilder: (context, index) {
              final category = groupedCategories[index];
              final categoryName = category['category'];
              final choices = category['choices'];
              final isMandatory = category['mandatory'] ?? false;

              // Label "Wajib" atau "Optional"
              String label = isMandatory ? "Wajib" : "Optional";

              // Gunakan fungsi buildCategory untuk menghindari pengulangan
              return _buildCategory(categoryName, choices, label);
            },
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

  // Fungsi untuk membangun kategori radio dan checkbox
  Widget _buildCategory(String categoryName, List choices, String label) {
    bool isRadioCategory = categoryName == "Size" ||
        categoryName == "Sweetness" ||
        categoryName == "Ice Cube";

    if (isRadioCategory) {
      return _buildRadioCategory(categoryName, choices, label);
    } else if (categoryName == "Topping") {
      return _buildCheckboxCategory(categoryName, choices, label);
    }

    return Container(); // Return empty container if not a valid category
  }

  // Fungsi untuk membangun kategori radio
  Widget _buildRadioCategory(String categoryName, List choices, String label) {
  String? selectedValue;

  if (categoryName == "Size") {
    selectedValue = _selectedSize;
  } else if (categoryName == "Sweetness") {
    selectedValue = _selectedSweetness;
  } else if (categoryName == "Ice Cube") {
    selectedValue = _selectedIceCube;
  }

  // Hanya tampilkan label "Wajib" sekali untuk kategori yang sesuai
  if (categoryName == "Size" || categoryName == "Sweetness" || categoryName == "Ice Cube") {
    label = "Wajib";
  } else {
    label = "Optional";
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              label, // Menampilkan label sesuai kategori
              style: TextStyle(fontSize: 11, color: Colors.black38),
            ),
          ],
        ),
        Column(
          children: choices.map<Widget>((choice) {
            return RadioListTile<String>(
              title: Text(choice['name'],
              style: TextStyle(
      fontFamily: 'Poppins', 
      fontSize: 14, 
      fontWeight: FontWeight.w500,
    ),
    ),
              subtitle: choice['additional_price'] != null
                  ? Text('Rp ${choice['additional_price']}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
          )
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


  // Fungsi untuk membangun kategori checkbox
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
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      fontFamily: 'Poppins', 
    ),
  ),
  Text(
    label,
    style: TextStyle(
      fontSize: 11,
      color: Colors.black38,
      fontFamily: 'Poppins', 
      fontWeight: FontWeight.w500, 
    ),
  ),
],

          ),
          Column(
            children: choices.map<Widget>((choice) {
              return CheckboxListTile(
                title: Text(choice['name'],
                style: TextStyle(
      fontFamily: 'Poppins', 
      fontSize: 14, 
      fontWeight: FontWeight.w500, 
    ),),
                subtitle: choice['additional_price'] != null
                    ? Text('Rp ${choice['additional_price']}',
                    style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),)
                    : null,
                value: _selectedToppings.contains(choice['name']),
                controlAffinity: ListTileControlAffinity.trailing,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
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
