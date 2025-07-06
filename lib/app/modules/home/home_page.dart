import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digimon SoftToken'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshDigimon();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // OTP Card
              _buildOtpCard(context),

              SizedBox(height: 20),

              // Digimon Card
              _buildDigimonCard(context),

              SizedBox(height: 20),

              // Status Card
              _buildStatusCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Código OTP',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Icon(
                  Icons.security,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),

            SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).primaryColor),
              ),
              child: Column(
                children: [
                  Obx(() => Text(
                    controller.currentOtp.value,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'monospace',
                    ),
                  )),

                  SizedBox(height: 8),

                  Obx(() => Text(
                    'Renovación en ${controller.formattedTimeRemaining}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  )),

                  SizedBox(height: 8),

                  Obx(() => LinearProgressIndicator(
                    value: controller.timeRemaining.value / 30,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigimonCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Digimon Actual',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Obx(() => controller.isLoading.value
                    ? SpinKitFadingCircle(
                  color: Theme.of(context).primaryColor,
                  size: 24,
                )
                    : IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: controller.refreshDigimon,
                )),
              ],
            ),

            SizedBox(height: 16),

            Obx(() {
              if (controller.currentDigimon.value == null) {
                return Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay Digimon disponible',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final digimon = controller.currentDigimon.value!;
              return InkWell(
                onTap: controller.viewDigimonDetail,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue[50]!,
                        Colors.purple[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: digimon.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.image, color: Colors.grey[600]),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(Icons.error, color: Colors.grey[600]),
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              digimon.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),

                            SizedBox(height: 4),

                            if (digimon.levels.isNotEmpty)
                              Text(
                                'Nivel: ${digimon.levels.join(', ')}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),

                            if (digimon.types.isNotEmpty)
                              Text(
                                'Tipo: ${digimon.types.join(', ')}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),

                            SizedBox(height: 8),

                            Row(
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Toca para ver detalles',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado del Sistema',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            SizedBox(height: 16),

            Obx(() => _buildStatusItem(
              icon: Icons.person,
              title: 'Usuario',
              value: controller.nickname.value,
              context: context,
            )),

            Obx(() => _buildStatusItem(
              icon: Icons.access_time,
              title: 'Última actualización',
              value: controller.lastUpdate.value.isEmpty
                  ? 'No disponible'
                  : controller.lastUpdate.value,
              context: context,
            )),

            Obx(() => controller.errorMessage.value.isNotEmpty
                ? Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 12),
          Text(
            '$title:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 8),
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

  void _showSettingsDialog(BuildContext context) {
    final TextEditingController nicknameController = TextEditingController();
    nicknameController.text = controller.nickname.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configuración'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                labelText: 'Nickname',
                hintText: 'Ingresa tu nickname',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateNickname(nicknameController.text);
              Navigator.of(context).pop();
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }
}