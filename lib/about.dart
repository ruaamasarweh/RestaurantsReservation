import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/menu_tab.dart';
import 'package:restaurants/models/branch_class.dart';
import 'package:restaurants/models/resraurant_class.dart';
import 'package:restaurants/details_tab.dart';
import 'package:restaurants/order_tab.dart';
import 'package:restaurants/providers/favorite_branches_provider.dart';
import 'package:restaurants/reviews_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class About extends StatefulWidget {
  final Restaurant restaurant;
  final BranchDto branch;
  final int? reservationID;
  const About({super.key, required this.restaurant, required this.branch,this.reservationID});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> with SingleTickerProviderStateMixin {
  
  late final TabController _tabController =TabController(length:widget.reservationID!=null?4:3, vsync: this);
 int? customerID;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
void initState() {
  super.initState();
  _initializeData();
}

Future<void> _initializeData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    customerID = prefs.getInt('customerID');
    log(customerID.toString());
  });

  if (customerID != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteBranchesProvider>(context, listen: false)
          .getFavBranches(customerID!);
    });
  }
}



  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final favoriteBranchesProvider=Provider.of<FavoriteBranchesProvider>(context);
    bool isFavorite = favoriteBranchesProvider.isFavorite(widget.branch.branchID);

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: screenHeight * 0.32,
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Container(
                        height: screenHeight * 0.32,
                        width: screenWidth,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.branch.branchImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: IconButton(
                            icon: Icon( isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : Colors.white,),
                            onPressed: () {
                             favoriteBranchesProvider.addRemoveFav(customerID!, widget.branch.branchID);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(  
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.orange,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs:  [
                     const Tab(text: 'Details'),
                      const Tab(text: 'Menu'),
                      const Tab(text: 'Reviews'),
                      if(widget.reservationID!=null)const Tab(text: 'Order'),
                      
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              DetailsTab(restaurant: widget.restaurant,branch: widget.branch,reservationID:widget.reservationID),
              MenuTab(restaurant:widget.restaurant),
              ReviewsTab(restaurant: widget.restaurant,branch:widget.branch),
           if(widget.reservationID!=null) OrderTab(restaurant: widget.restaurant,branch:widget.branch, reservationID:widget.reservationID!),           
            ],
          ),
        ),
      ),
      
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
