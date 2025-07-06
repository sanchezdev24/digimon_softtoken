import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'digimon_detail_controller.dart';

class DigimonDetailPage extends GetView<DigimonDetailController> {
  const DigimonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(context),
                  SizedBox(height: 24),
                  _buildAttributes(context),
                  SizedBox(height: 24),
                  _buildLevels(context),
                  SizedBox(height: 24),
                  _buildTypes(context),
                  if (controller.digimon.description != null) ...[
                    SizedBox(height: 24),
                    _buildDescription(context),
                  ],
                  SizedBox(height: 24),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          controller.digimon.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: controller.digimon.image,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.error,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Información Básica',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Nombre', controller.digimon.name, context),
            _buildInfoRow('ID', controller.digimon.id, context),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributes(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Atributos',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.digimon.attributes.map((attribute) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getAttributeColor(attribute),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    attribute,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevels(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Niveles',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.digimon.levels.map((level) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypes(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Tipos',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.digimon.types.map((type) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Descripción',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              controller.digimon.description!,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back),
            label: Text('Volver'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Share functionality could be added here
              Get.snackbar(
                'Compartir',
                'Función de compartir no implementada',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: Icon(Icons.share),
            label: Text('Compartir'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttributeColor(String attribute) {
    switch (attribute.toLowerCase()) {
      case 'vaccine':
        return Colors.green;
      case 'virus':
        return Colors.red;
      case 'data':
        return Colors.blue;
      case 'free':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}