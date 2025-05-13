import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Tüm Harcamaları Sil'),
                subtitle: const Text('Tüm harcama verilerini kalıcı olarak siler'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Tüm Harcamaları Sil'),
                      content: const Text(
                        'Tüm harcama verileriniz kalıcı olarak silinecek. Bu işlem geri alınamaz.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<ExpenseProvider>(context, listen: false)
                                .deleteAllExpenses();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tüm harcamalar silindi'),
                              ),
                            );
                          },
                          child: const Text(
                            'Sil',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Uygulama Hakkında'),
                subtitle: const Text('Versiyon 1.0.0'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Harcama Takibi',
                    applicationVersion: '1.0.0',
                    applicationIcon: const FlutterLogo(size: 64),
                    children: const [
                      Text(
                        'Harcama Takibi uygulaması, günlük harcamalarınızı takip etmenize ve kategorilere göre analiz etmenize yardımcı olur.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
} 