// Tugas no 3
// sistem Gacha Game

import 'dart:io';
import 'dart:math';

// abstraction 
abstract class ItemGacha {
  String _nama;
  int _rarity;

  ItemGacha(this._nama, this._rarity);

  String get nama => _nama;
  int get rarity => _rarity;

  set rarity(int value) {
    if (value >= 1 && value <= 5) {
      _rarity = value;
    }
  }

  void efekItem();
}


// inheritance
class Hero extends ItemGacha {
  Hero(String nama, int rarity) : super(nama, rarity);

  @override
  void efekItem() {
    print("$nama siap bertarung!");
  }
}

class Senjata extends ItemGacha {
  Senjata(String nama, int rarity) : super(nama, rarity);

  @override
  void efekItem() {
    print("$nama meningkatkan attack!");
  }
}

class MesinGacha {
  Random random = Random();

  ItemGacha tarik() {
    int angka = random.nextInt(6);

    if (angka == 0) {
      return Hero("Dragon Knight", 5);
    } else if (angka == 1) {
      return Hero("Shadow Assassin", 4);
    } else if (angka == 2) {
      return Hero("Elf Archer", 3);
    } else if (angka == 3) {
      return Senjata("Excalibur", 5);
    } else if (angka == 4) {
      return Senjata("Magic Staff", 4);
    } else {
      return Senjata("Wooden Sword", 2);
    }
  }
  
}


void continueGame() {
  stdout.write("\nPress Enter to continue...");
  stdin.readLineSync();
}


void main() {
  MesinGacha mesin = MesinGacha();

  List<ItemGacha> inventory = [];

  bool jalan = true;

  while (jalan) {
    print("\n==============================");
    print("     ARCANE PULL     ");
    print("==============================");
    print("1. Gacha 1x");
    print("2. Lihat Inventory");
    print("3. Upgrade Rarity Item Pertama");
    print("4. Keluar");
    stdout.write("Pilih menu : ");

    String? pilihan = stdin.readLineSync();

    switch (pilihan) {
      case "1":
        ItemGacha item = mesin.tarik();

        inventory.add(item);

        print("\n       HASIL GACHA:");
        print("Item   : ${item.nama}");
        print("Rarity : ${item.rarity} Bintang");

        item.efekItem();

        continueGame();
        break;


      // polimorphism
      case "2":
        print("\n      INVENTORY: ");

        if (inventory.isEmpty) {
          print("Inventory masih kosong.");
        } else {
          int nomor = 1;

          for (ItemGacha item in inventory) {
            print("\nItem $nomor");
            print("Nama   : ${item.nama}");
            print("Rarity : ${item.rarity} Bintang");

            // polimorphism
            item.efekItem();

            nomor++;
          }
        }

        continueGame();
        break;

      // encapsulation 
      case "3":
        if (inventory.isEmpty) {
          print("\nInventory kosong.");
        } else {
          inventory.first.rarity = 5;

          print("\nItem pertama berhasil di-upgrade!");

          print("Nama   : ${inventory.first.nama}");
          print("Rarity : ${inventory.first.rarity} Bintang");
        }

        continueGame();
        break;


      case "4":
        print("\nTerima kasih sudah bermain.");
        jalan = false;
        break;

      default:
        print("\nMenu tidak tersedia.");
        continueGame();
    }
  }
}