import 'dart:io';

import 'package:ecommerce/core/status_util.dart';
import 'package:ecommerce/custom/custom_button.dart';
import 'package:ecommerce/custom/custom_textformfield.dart';
import 'package:ecommerce/model/user.dart';
import 'package:ecommerce/provider/user_provider.dart';
import 'package:ecommerce/utils/Helper.dart';
import 'package:ecommerce/utils/color_const.dart';
import 'package:ecommerce/utils/string_const.dart';
import 'package:ecommerce/view/signin_form.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  User? user;

  List<String> adminFunctions = [
    "Add Product",
    "Customer List",
    "Sold Products"
  ];
  int selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> widgetOptions = <Widget>[
    Text(
      'Add Product',
      style: optionStyle,
    ),
    Text(
      'Customer List',
      style: optionStyle,
    ),
    Text(
      'Sold Products',
      style: optionStyle,
    ),
  ];
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getValue();
  }

  String? userName, userEmail, userRole;
  bool isLoading = true;
  getValue() {
    Future.delayed(
      Duration.zero,
      () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        userName = prefs.getString("userName");
        userEmail = prefs.getString("userEmail");
        userRole = prefs.getString("userRole");
        setState(() {
          // user = User(email: userEmail, name: userName, role: userRole);
          isLoading = false;
        });
      },
    );
  }

  File file = File("");
  bool loader = false;
  final _formKey = GlobalKey<FormState>();
  String? productName, price, description;
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    //admin page starts from here
    return userRole == "admin"
        ? Consumer<UserProvider>(
            builder: (context, userProvider, child) => SafeArea(
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor: backGroundColor,
                      title: Text(
                        userName ?? "",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      leading: Builder(
                        builder: (context) {
                          return IconButton(
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                              icon: Icon(
                                Icons.menu,
                                color: Colors.white,
                              ));
                        },
                      ),
                      actions: [
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.settings,
                                  size: 30,
                                  color: Colors.white,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage("assets/images/user.png")),
                            ),
                          ],
                        )
                      ],
                    ),
                    drawer: Drawer(
                        child: ListView(
                      children: [
                        DrawerHeader(
                            decoration: BoxDecoration(color: backGroundColor),
                            child: Text(
                              "Admin Panel",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            )),
                        ListTile(
                          title: const Text('Add Product'),
                          selected: selectedIndex == 0,
                          onTap: () {
                            onItemTapped(0);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Customer List'),
                          selected: selectedIndex == 1,
                          onTap: () {
                            onItemTapped(1);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text('Sold Products'),
                          selected: selectedIndex == 2,
                          onTap: () {
                            onItemTapped(2);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    )),
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              widgetOptions[selectedIndex],
                            ],
                          ),
                          if (selectedIndex == 0)
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  file.path.isEmpty
                                      ? SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: ClipRRect(
                                            child: Image.asset(
                                              "assets/images/add-product.png",
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: ClipRRect(
                                            child: Image.file(file),
                                          ),
                                        ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.50,
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    child: CustomButton(
                                        backgroundColor: backGroundColor,
                                        onPressed: () {
                                          pickImage();
                                        },
                                        child: loader == true
                                            ? CircularProgressIndicator()
                                            : Text(
                                                "Upload Image",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10),
                                    child: CustomTextFormField(
                                      onChanged: (value) {
                                        productName = value;
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return productNameValidationStr;
                                        }
                                        return null;
                                      },
                                      labelText: "Product name",
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10),
                                    child: CustomTextFormField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        price = value;
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return priceValidationStr;
                                        }
                                        return null;
                                      },
                                      labelText: "Price",
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 10),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        description = value;
                                      },
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return descriptionValidationStr;
                                        }
                                      },
                                      maxLines:
                                          null, // Allows the TextFormField to grow dynamically
                                      minLines:
                                          10, // Sets a minimum number of lines
                                      keyboardType: TextInputType
                                          .multiline, // Allows multiline input
                                      decoration: InputDecoration(
                                        hintText:
                                            'Description of the Product...',
                                        border:
                                            OutlineInputBorder(), // Adds a border around the text area
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  CustomButton(
                                    backgroundColor: backGroundColor,
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {}
                                    },
                                    child: Text("Submit",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  CustomButton(
                                    onPressed: () {
                                      logoutShowDialog(context, userProvider);
                                    },
                                    child: Text("Logout"),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                    // Column(
                    //   children: [
                    //     Container(
                    //       color: backGroundColor,
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [],
                    //       ),
                    //     ),
                    //     CustomButton(
                    //       onPressed: () {
                    //         logoutShowDialog(context, userProvider);
                    //       },
                    //       child: Text("Logout"),
                    //     ),
                    //   ],
                    // ),
                  ),
                ))
        //userPage starts from here
        : Consumer<UserProvider>(
            builder: (context, userProvider, child) => SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: backGroundColor,
                  title: Text(
                    userName ?? "",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  leading: Builder(
                    builder: (context) {
                      return IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ));
                    },
                  ),
                  actions: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.settings,
                              size: 30,
                              color: Colors.white,
                            )),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage("assets/images/user.png")),
                        ),
                      ],
                    )
                  ],
                ),
                drawer: Drawer(
                  child: Text(
                    "hello",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                body: Column(
                  children: [
                    Container(
                      color: buttonBackgroundColor,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "My WishList",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    "10",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Text("Vouchers",
                                      style: TextStyle(color: Colors.white)),
                                  Text("10",
                                      style: TextStyle(color: Colors.white))
                                ],
                              ),
                              Column(
                                children: [
                                  Text("Stores",
                                      style: TextStyle(color: Colors.white)),
                                  Text("10",
                                      style: TextStyle(color: Colors.white))
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Color(0xffF6F6F6),
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "My Orders",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text("View All",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                        "assets/images/package_box_alt.png"),
                                    Text("To Pay")
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Image.asset("assets/images/package.png"),
                                  Text("To Ship")
                                ],
                              ),
                              Column(
                                children: [
                                  Image.asset("assets/images/package_car.png"),
                                  Text("To Receive")
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Column(
                                  children: [
                                    Image.asset("assets/images/Chat_alt_3.png"),
                                    Text("Chat")
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, right: 10.0, bottom: 10),
                            child: Row(
                              children: [
                                Image.asset(
                                    "assets/images/Refund_back_light.png"),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("My Returns"),
                                Spacer(),
                                Image.asset(
                                    "assets/images/package_cancellation.png"),
                                SizedBox(
                                  width: 5,
                                ),
                                Text("My Cancellations")
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      color: Color(0xffF6F6F6),
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "My Services",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text("View All",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Column(
                                  children: [
                                    Image.asset("assets/images/Message.png"),
                                    Text("Messages")
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Image.asset("assets/images/Credit_card.png"),
                                  Text("Payment")
                                ],
                              ),
                              Column(
                                children: [
                                  Image.asset("assets/images/Question.png"),
                                  Text("Help")
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Column(
                                  children: [
                                    Image.asset("assets/images/Send_fill.png"),
                                    Text("To Review")
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      color: Color(0xffF6F6F6),
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: const Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "Location Tracker of Products Arrival",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  "Country: ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  "Nepal",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  "City: ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  "Bhaktapur",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Row(
                              children: [
                                Text(
                                  "Exact Location: ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  "Sanotimi",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 10),
                            child: Row(
                              children: [
                                Text(
                                  "Arrival Time: ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Text(
                                  "0days, 3hrs",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                      onPressed: () {
                        logoutShowDialog(context, userProvider);
                      },
                      child: Text("Logout"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                      onPressed: () async {
                        createShowDialog(context, userProvider);
                      },
                      child:
                          userProvider.getDeleteUserStatus == StatusUtil.loading
                              ? CircularProgressIndicator()
                              : Text("Delete"),
                    )
                  ],
                ),
              ),
            ),
          );
  }

  logoutUserFromSharedPreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
    Helper.displaySnackbar(context, "Successfully Logged Out!");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SigninPage(),
        ),
        (route) => false);
  }

  createShowDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete File'),
          content: Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              onPressed: () async {
                await userProvider.deleteUserData();
                if (userProvider.getDeleteUserStatus == StatusUtil.success) {
                  Helper.displaySnackbar(context, "Data Successfully deleted");
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SigninPage(),
                      ),
                      (route) => false);
                }
                // Perform delete operation here
                // Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  logoutShowDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to Logout?'),
          actions: [
            TextButton(
              onPressed: () async {
                logoutUserFromSharedPreference();
                Helper.displaySnackbar(context, "Logout Successfull!");
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SigninPage(),
                    ),
                    (route) => false);

                // Perform delete operation here
                // Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  pickImage() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    file = File(image!.path);
    setState(() {
      loader = true;
      file;
    });
    try {
      // List<String> fileName = file.path.split('/');
      String fileName = file.path.split('/').last;
      var storageReference = FirebaseStorage.instance.ref();
      var uploadReference = storageReference.child(fileName);
      await uploadReference.putFile(file);
      String? downloadUrl = await uploadReference.getDownloadURL();
      setState(() {
        loader = false;
      });
      // print("downloadUrl$downloadUrl");
    } catch (e) {
      setState(() {
        loader = false;
      });
    }
  }
}
