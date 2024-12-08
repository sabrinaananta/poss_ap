import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posproject/components/CardOrderItem.dart'; // Package untuk format Rupiah

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int subtotal = 170000; // Total harga barang sebelum pajak, servis, dan diskon
  double taxRate = 0.05; // Persentase pajak (5%)
  double serviceRate = 0.1; // Persentase biaya layanan (10%)
  String promoCode = ''; // Menyimpan kode promo yang dimasukkan pengguna
  int discount = 0; // Nilai diskon yang diterapkan setelah validasi kode promo
  bool isPromoValid = false; // Status apakah kode promo valid
  String userName = ''; // Menyimpan nama pengguna
  String userPhone = ''; // Menyimpan nomor telepon pengguna

  // Daftar kode promo yang valid
  final validPromoCodes = {
    'DISKON10': 10000,
    'DISKON50': 50000,
  };

  // Fungsi untuk memformat nilai ke dalam format Rupiah
  String _formatRupiah(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  // Fungsi untuk menerapkan kode promo yang dimasukkan oleh pengguna
  void _applyPromoCode() {
    setState(() {
      // Mengecek apakah kode promo valid dan menerapkan diskon
      if (validPromoCodes.containsKey(promoCode)) {
        discount = validPromoCodes[promoCode]!; // Terapkan diskon
        isPromoValid = true;
      } else {
        discount = 0; // Reset diskon jika kode promo tidak valid
        isPromoValid = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  CardOrderItem(name: 'caramel Cipi'),
                  _buildCartItem(
                    'Caramel Coffee',
                    'Large, 100% Ice, 60% Sugar',
                    70000,
                    '',
                  ),
                  SizedBox(height: 16),
                  _buildCartItem(
                    'French Fries',
                    '',
                    100000,
                    '',
                  ),
                  SizedBox(height: 16),
                  _buildUserInfoForm(), // Form untuk nama dan nomor telepon
                  SizedBox(height: 16),
                  _buildTaxAndServiceSelector(), // Pajak dan layanan
                  SizedBox(height: 16),
                  _buildPromoCodeField(), // Input kode promo
                  SizedBox(height: 16),
                  _buildOrderSummary(), // Ringkasan pesanan
                  SizedBox(height: 16),
                  _buildProcessTransactionButton(), // Tombol transaksi
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(
      String name, String details, int price, String imagePath) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          child: Center(
            child: Icon(Icons.image, color: Colors.white),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              if (details.isNotEmpty)
                Text(
                  details,
                  style: TextStyle(color: Colors.grey),
                ),
              SizedBox(height: 8),
              Text(
                _formatRupiah(price),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget untuk form input nama dan nomor telepon
  Widget _buildUserInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8),
        TextField(
          onChanged: (value) {
            setState(() {
              userName = value;
            });
          },
          decoration: InputDecoration(
            labelText: 'Enter Full Name',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Nomor Telepon',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8),
        TextField(
          onChanged: (value) {
            setState(() {
              userPhone = value;
            });
          },
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Masukkan Nomor Telepon',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxAndServiceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tax & Service Options',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax'),
            DropdownButton<double>(
              value: taxRate,
              onChanged: (value) {
                setState(() {
                  taxRate = value!;
                });
              },
              items: [
                DropdownMenuItem(
                  value: 0.05,
                  child: Text('5%'),
                ),
                DropdownMenuItem(
                  value: 0.0,
                  child: Text('No Tax'),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Service'),
            DropdownButton<double>(
              value: serviceRate,
              onChanged: (value) {
                setState(() {
                  serviceRate = value!;
                });
              },
              items: [
                DropdownMenuItem(
                  value: 0.1,
                  child: Text('10%'),
                ),
                DropdownMenuItem(
                  value: 0.0,
                  child: Text('No Service'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromoCodeField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              promoCode = value;
            },
            decoration: InputDecoration(
              labelText: 'Enter Promo Code',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: _applyPromoCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Warna latar belakang tombol
            foregroundColor: Colors.white, // Warna teks
          ),
          child: Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    int tax = (subtotal * taxRate).round();
    int service = (subtotal * serviceRate).round();
    int total = subtotal + tax + service - discount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal'),
            Text(_formatRupiah(subtotal)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax (${(taxRate * 100).toInt()}%)'),
            Text(_formatRupiah(tax)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Service (${(serviceRate * 100).toInt()}%)'),
            Text(_formatRupiah(service)),
          ],
        ),
        if (isPromoValid)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discount (Promo Code)'),
              Text('-${_formatRupiah(discount)}'),
            ],
          ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _formatRupiah(total),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProcessTransactionButton() {
    return ElevatedButton(
      onPressed: () {
        // Logika untuk memproses transaksi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction Processed'),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      child: Text('Process Transaction'),
    );
  }
}
