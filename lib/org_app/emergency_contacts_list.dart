import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EmergencyContactListScreen extends StatelessWidget {
  const EmergencyContactListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emergencyContactsBox = Hive.box('emergencyContacts');

    return Scaffold(
      appBar: AppBar(title: Text("Emergency Contacts")),
      body: ValueListenableBuilder(
        valueListenable: emergencyContactsBox.listenable(),
        builder: (context, Box box, _) {
          final contacts = box.values.toList().cast<Map>();
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                title: Text(contact['name']),
                subtitle: Text(contact['relation']),
                trailing: Text(contact['phone']),
                onTap: () => context.push('/add-emergency-contact',
                    extra: {'contact': contact, 'index': index}),
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
