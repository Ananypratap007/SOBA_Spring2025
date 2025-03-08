import 'package:flutter/material.dart';
import 'package:soba_app/profile/profile_presenter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.presenter,
  });

  final ProfilePresenter presenter;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
