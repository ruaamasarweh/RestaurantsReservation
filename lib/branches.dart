import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/about.dart';
import 'package:restaurants/models/branch_class.dart';
import 'package:restaurants/models/resraurant_class.dart';
import 'package:restaurants/providers/branches_provider.dart';
import 'package:restaurants/providers/favorite_branches_provider.dart';

class Branches extends StatefulWidget {
  final Restaurant? restaurant; 
  final List<Restaurant>? favs;
  final int? userID;
  const Branches({super.key, this.restaurant, this.favs, this.userID});

  @override
  State<Branches> createState() => _BranchesState();
}

class _BranchesState extends State<Branches> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.restaurant != null) {
        Provider.of<BranchesProvider>(context, listen: false)
            .fetchBranches(widget.restaurant!.restaurantID);
      } else if (widget.userID != null) {
        Provider.of<FavoriteBranchesProvider>(context, listen: false)
            .getFavBranches(widget.userID!);
      }
    });
  }

  Future<void> _refreshBranches() async {
    if (widget.restaurant != null) {
      await Provider.of<BranchesProvider>(context, listen: false)
          .fetchBranches(widget.restaurant!.restaurantID);
    } else if (widget.userID != null) {
      await Provider.of<FavoriteBranchesProvider>(context, listen: false)
          .getFavBranches(widget.userID!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branchProvider = Provider.of<BranchesProvider>(context);
    final favBranchProvider = Provider.of<FavoriteBranchesProvider>(context);

    final isFavoriteMode = widget.restaurant == null;

    return Scaffold(
      appBar: AppBar(
        title:  Text( isFavoriteMode ? 'Favorites' : 'Branches',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(151, 212, 212, 212),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBranches,
        child: isFavoriteMode
            ? favBranchProvider.favs.isEmpty && favBranchProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: favBranchProvider.favs.length,
                      itemBuilder: (context, restaurantIndex) {
                        final restaurant = favBranchProvider.favs[restaurantIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: restaurant.branches!.map((branch) {
                            return _buildBranchCard(restaurant, branch);
                          }).toList(),
                        );
                      },
                    ),
                  )
            : branchProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: branchProvider.branches.length,
                      itemBuilder: (context, index) {
                        final branch = branchProvider.branches[index];
                        return _buildBranchCard(widget.restaurant!, branch);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildBranchCard(Restaurant restaurant, BranchDto branch) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => About(
              restaurant: restaurant,
              branch: branch,
            ),
          ),
        );
      },
      splashColor: const Color.fromARGB(255, 202, 197, 197),
      child: SizedBox(
        width: double.infinity,
        height: 160,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 120,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(branch.branchImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color.fromARGB(255, 255, 117, 25), size: 18),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              branch.locationDescription,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 20, color: Color.fromARGB(255, 185, 83, 0)),
                        ],
                      ),
                      Text(
                        restaurant.restaurantName,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
