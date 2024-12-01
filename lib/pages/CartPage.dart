import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Package untuk format Rupiah

// Halaman CartPage
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
          'Order', // Judul halaman
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
                  // Membuat item contoh
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
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildTaxAndServiceSelector(), // Memilih pajak dan biaya layanan
            SizedBox(height: 16),
            _buildPromoCodeField(), // Input untuk kode promo
            SizedBox(height: 16),
            _buildOrderSummary(), // Menampilkan ringkasan pesanan
            SizedBox(height: 16),
            _buildProcessTransactionButton(), // Tombol untuk memproses transaksi
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan itemnya
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
                name, // Nama item
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              if (details.isNotEmpty) // Menampilkan detail jika ada
                Text(
                  details,
                  style: TextStyle(color: Colors.grey),
                ),
              SizedBox(height: 8),
              Text(
                _formatRupiah(price), // Menampilkan harga dalam format Rupiah
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget untuk memilih pajak dan biaya layanan
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

  // Widget untuk input kode promo
  Widget _buildPromoCodeField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              promoCode = value; // Mengambil input kode promo
            },
            decoration: InputDecoration(
              labelText: 'Enter Promo Code',
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
              ),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8),
        // Tombol untuk menerapkan kode promo
        ElevatedButton(
          onPressed: _applyPromoCode,
          child: Text(
            'Apply',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  // Widget untuk menampilkan ringkasan pesanan
  Widget _buildOrderSummary() {
    int tax = (subtotal * taxRate).round(); // Menghitung pajak
    int service = (subtotal * serviceRate).round(); // Menghitung biaya layanan
    int total = subtotal + tax + service - discount; // Total yang harus dibayar

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8),
        // Menampilkan subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal'),
            Text(_formatRupiah(subtotal)),
          ],
        ),
        // Menampilkan pajak
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax (${(taxRate * 100).toInt()}%)'),
            Text(_formatRupiah(tax)),
          ],
        ),
        // Menampilkan biaya layanan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Service (${(serviceRate * 100).toInt()}%)'),
            Text(_formatRupiah(service)),
          ],
        ),
        if (isPromoValid) // Menampilkan diskon jika kode promo valid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discount (Promo Code)'),
              Text('-${_formatRupiah(discount)}'),
            ],
          ),
        SizedBox(height: 16),
        // Menampilkan total harga
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              _formatRupiah(total),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget untuk tombol pemrosesan transaksi
  Widget _buildProcessTransactionButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Navigasi atau proses pemesanan setelah tombol ditekan
        },
        child: Text(
          'Process Transaction',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
