import '../model/employee_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import '../providers/db_provider.dart';
import '../providers/employee_api_provider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLoading = false;
  List<Employee> employees = [];
  List<Employee> listData = [];
  bool isSearch = false;

  @override
  void initState() {
    _loadFromDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearch
            ? null
            : Text('Employees',
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: -0.8,
                  color: Colors.white,
                )),
        centerTitle: false,
        backgroundColor: Colors.blue,
        elevation: 2,
        automaticallyImplyLeading: false,
        // titleSpacing: 0,
        actions: isSearch ? appBarWithSearch() : defaultAppBarIcons(),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildEmployeeListView(),
    );
  }

  List<Widget> appBarWithSearch() {
    return [
      Flexible(
          child: Container(
        alignment: Alignment.center,
        child: TextField(
          onChanged: searchOperation,
          style: TextStyle(fontFamily: 'Montserrat', color: Colors.white),
          decoration: new InputDecoration(
              contentPadding: EdgeInsets.only(top: 20.0),
              prefixIcon: Container(
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    print("Search false");
                  },
                ),
              ),
              hintText: "Search...",
              hintStyle: new TextStyle(color: Colors.grey[400])),
        ),
      )),
      Container(
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
          //  color: Color(0xFF2e64bc),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            print("Search false");
            searchCloseOperation();
          },
        ),
      ),
    ];
  }

  List<Widget> defaultAppBarIcons() {
    return [
      Container(
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            print("Search true");
            setState(() {
              isSearch = true;
            });
          },
        ),
      ),
      Container(
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
          // color: Color(0xFF2e64bc),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.get_app,
            color: Colors.white,
          ),
          onPressed: () async {
            await _loadFromApi();
          },
        ),
      ),
    ];
  }

  void searchOperation(String searchText) {
    print(searchText);

    setState(() {
      if (searchText.length != 0) {
        var searchedName = employees
            .where((i) =>
                i.name.toLowerCase().contains(searchText.toLowerCase()) ||
                "${i.name} ".toLowerCase().contains(searchText.toLowerCase()) ||
                i.email.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
        listData = searchedName;
      } else {
        listData = employees;
      }
    });
  }

  void searchCloseOperation() {
    setState(() {
      isSearch = false;
      listData = employees;
    });
  }

  _loadFromDB() async {
    await DBProvider.db.getAllEmployees().then((value) {
      setState(() {
        employees = value;
        listData = value;
      });
    });
  }

  _loadFromApi() async {
    setState(() {
      isLoading = true;
    });

    var apiProvider = EmployeeApiProvider();
    await apiProvider.getAllEmployees();
    _loadFromDB();
    // wait for 2 seconds to simulate loading of data
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

  _deleteData() async {
    setState(() {
      isLoading = true;
    });

    await DBProvider.db.deleteAllEmployees();

    // wait for 1 second to simulate loading of data
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });

    print('All employees deleted');
  }

  _buildEmployeeListView() {
    return ListView.builder(
      itemCount: listData.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: Text(
            "${index + 1}",
            style: TextStyle(fontSize: 20.0),
          ),
          title: Text("Name: ${listData[index].name}"),
          subtitle: Text('EMAIL: ${listData[index].email}'),
          onTap: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => DetailPage(listData[index])));
          },
        );
      },
    );
    ;
  }
}

class DetailPage extends StatelessWidget {
  final Employee employee;
  DetailPage(this.employee);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employee.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.network(employee.profileImage),
          Text(employee.name),
          //Text(employee.userame),
          Text(employee.email),
          //Text(employee.address),
          Text(employee.phone),
          Text(employee.website),
          //Text(employee.company),
        ],
      ),
    );
  }
}
