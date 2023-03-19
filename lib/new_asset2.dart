import 'package:flutter/material.dart';

class AssetSelectionDialog2 extends StatelessWidget {
  const AssetSelectionDialog2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: Colors.black38,
      title: const Center(child: Text('Choose yourself')),
      content: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        width: double.maxFinite,
        height: size.height / 5,
        child: GridView.count(
          physics: const BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.normal),
          crossAxisCount: 3,
          children: [
            _buildAssetTile('assets/images/folder4.gif', context),
            _buildAssetTile('assets/images/folder5.gif', context),
            _buildAssetTile('assets/images/folder6.gif', context),
            _buildAssetTile('assets/images/folder7.gif', context),
            _buildAssetTile('assets/images/folder8.gif', context),
            _buildAssetTile('assets/images/folder9.gif', context),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTile(String assetPath2, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(assetPath2);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          assetPath2,
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
