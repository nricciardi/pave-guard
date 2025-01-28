import 'package:admin/controllers/query_manager.dart';

import '../../../controllers/menu_app_controller.dart';
import '../../../responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  final MeData data;
  final String title;
  final bool show_searchbar;
  final void Function(String)? onSubmitted;

  const Header(
    {
      required this.data,
      required this.title,
      this.show_searchbar = true,
      this.onSubmitted,
      Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuAppController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        if(show_searchbar)
          Expanded(child: SearchField(onSubmitted: onSubmitted)),
        ProfileCard(data.getFirstName(), data.getLastName()),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String surname;

  const ProfileCard(
    this.name,
    this.surname, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(Icons.account_circle, size: 38),
          if (!Responsive.isMobile(context))
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text("${name} ${surname}"),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                context.read<MenuAppController>().setScreen(MenuState.profile);
              } else if (value == 'logout') {
                context.read<MenuAppController>().logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'profile',
                  child: Text('Profile'),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final void Function(String)? onSubmitted;

  SearchField({
    this.onSubmitted,
    Key? key,
  }) : super(key: key);

  void onTap(){
    if(onSubmitted == null)
      return;
    onSubmitted!(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onSubmitted: (value) {
        onTap();
      },
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {
            onTap();
          },
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}
