import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmergencyContactListScreen extends StatelessWidget {
  const EmergencyContactListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emergencyContactsBox = Hive.box('emergencyContacts');

    return Scaffold(
      appBar: AppBar(title: const Text("Emergency Contacts")),
      body: ValueListenableBuilder(
        valueListenable: emergencyContactsBox.listenable(),
        builder: (context, Box box, _) {
          final contacts = box.values.toList().cast<Map>();
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(contact['name']),
                subtitle: Text(contact['relation']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(contact['phone']),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Contact"),
                            content: const Text(
                                "Are you sure you want to delete this contact?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await box.deleteAt(index);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () => context.push(
                  '/add-emergency-contact',
                  extra: {'contact': contact, 'index': index},
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-emergency-contact'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
