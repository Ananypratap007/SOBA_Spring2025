import 'package:flutter/material.dart';

class SmartTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;

  const SmartTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText = '',
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  _SmartTextFieldState createState() => _SmartTextFieldState();
}

class _SmartTextFieldState extends State<SmartTextField> {
  late FocusNode _focusNode;
  bool _showLabel = true;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _showLabel = !_focusNode.hasFocus && widget.controller.text.isEmpty;
      });
    });
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    setState(() {
      _showLabel = !_focusNode.hasFocus && widget.controller.text.isEmpty;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText && !_showPassword,
          keyboardType: widget.keyboardType,
          decoration: InputDecoration(
            labelText: _showLabel ? widget.label : null,
            hintText: widget.hintText, // Always visible hint text
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF4CAF93), width: 2),
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  )
                : null,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class DualInputField extends StatelessWidget {
  final TextEditingController firstController;
  final TextEditingController secondController;
  final String firstLabel;
  final String secondLabel;
  final String? firstHint;
  final String? secondHint;
  final TextInputType? firstInputType;
  final TextInputType? secondInputType;
  final String? Function(String?)? firstValidator;
  final String? Function(String?)? secondValidator;
  final double spacing;
  final double borderRadius; // New parameter for border radius
  final Color fillColor; // New parameter for fill color
  final VoidCallback? firstOnTap;
  final VoidCallback? secondOnTap;
  final bool firstReadOnly;
  final bool secondReadOnly;

  const DualInputField({
    super.key,
    required this.firstController,
    required this.secondController,
    required this.firstLabel,
    required this.secondLabel,
    this.firstHint,
    this.secondHint,
    this.firstInputType,
    this.secondInputType,
    this.firstValidator,
    this.secondValidator,
    this.spacing = 16.0,
    this.borderRadius = 12.0, // Default radius value
    this.fillColor = Colors.white, // Default fill color
    this.firstOnTap,
    this.secondOnTap,
    this.firstReadOnly = false,
    this.secondReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: firstController,
              readOnly: firstReadOnly,
              onTap: firstOnTap,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: firstLabel,
                hintText: firstHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Color(0xFF4CAF93), width: 2),
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              keyboardType: firstInputType,
              validator: firstValidator,
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: TextFormField(
              controller: secondController,
              readOnly: secondReadOnly,
              onTap: secondOnTap,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: secondLabel,
                hintText: secondHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              keyboardType: secondInputType,
              validator: secondValidator,
            ),
          ),
        ],
      ),
    );
  }
}

class TripleInputField extends StatelessWidget {
  final TextEditingController firstController;
  final TextEditingController stateController;
  final TextEditingController thirdController;
  final String firstLabel;
  final String secondLabel;
  final String thirdLabel;
  final String? firstHint;
  final String? secondHint;
  final String? thirdHint;
  final TextInputType? firstInputType;
  final TextInputType? thirdInputType;
  final String? Function(String?)? firstValidator;
  final String? Function(String?)? thirdValidator;
  final double spacing;
  final double borderRadius;
  final Color fillColor;
  final double middleFieldWidth;

  // US States map (full name → abbreviation)
  static const Map<String, String> usStates = {
    'Alabama': 'AL',
    'Alaska': 'AK',
    'Arizona': 'AZ',
    'Arkansas': 'AR',
    'California': 'CA',
    'Colorado': 'CO',
    'Connecticut': 'CT',
    'Delaware': 'DE',
    'District of Columbia': 'DC',
    'Florida': 'FL',
    'Georgia': 'GA',
    'Hawaii': 'HI',
    'Idaho': 'ID',
    'Illinois': 'IL',
    'Indiana': 'IN',
    'Iowa': 'IA',
    'Kansas': 'KS',
    'Kentucky': 'KY',
    'Louisiana': 'LA',
    'Maine': 'ME',
    'Maryland': 'MD',
    'Massachusetts': 'MA',
    'Michigan': 'MI',
    'Minnesota': 'MN',
    'Mississippi': 'MS',
    'Missouri': 'MO',
    'Montana': 'MT',
    'Nebraska': 'NE',
    'Nevada': 'NV',
    'New Hampshire': 'NH',
    'New Jersey': 'NJ',
    'New Mexico': 'NM',
    'New York': 'NY',
    'North Carolina': 'NC',
    'North Dakota': 'ND',
    'Ohio': 'OH',
    'Oklahoma': 'OK',
    'Oregon': 'OR',
    'Pennsylvania': 'PA',
    'Rhode Island': 'RI',
    'South Carolina': 'SC',
    'South Dakota': 'SD',
    'Tennessee': 'TN',
    'Texas': 'TX',
    'Utah': 'UT',
    'Vermont': 'VT',
    'Virginia': 'VA',
    'Washington': 'WA',
    'West Virginia': 'WV',
    'Wisconsin': 'WI',
    'Wyoming': 'WY',
  };

  const TripleInputField({
    super.key,
    required this.firstController,
    required this.stateController,
    required this.thirdController,
    required this.firstLabel,
    required this.secondLabel,
    required this.thirdLabel,
    this.firstHint,
    this.secondHint,
    this.thirdHint,
    this.firstInputType,
    this.thirdInputType,
    this.firstValidator,
    this.thirdValidator,
    this.spacing = 8.0,
    this.borderRadius = 12.0,
    this.fillColor = Colors.white,
    this.middleFieldWidth = 60.0,
  });

  // Helper to find full state name from abbreviation
  String? _getStateNameFromAbbreviation(String? abbrev) {
    if (abbrev == null || abbrev.isEmpty) return null;
    return usStates.entries
        .firstWhere(
          (entry) => entry.value == abbrev,
          orElse: () => const MapEntry('', ''),
        )
        .key;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // First field (City)
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: firstController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: firstLabel,
                hintText: firstHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Color(0xFF4CAF93), width: 2),
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              keyboardType: firstInputType,
              validator: firstValidator,
            ),
          ),
          SizedBox(width: spacing),

          // Middle field (State dropdown)
          SizedBox(
            width: middleFieldWidth,
            child: DropdownButtonFormField<String>(
              value:
                  stateController.text.isNotEmpty ? stateController.text : null,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: secondLabel,
                hintText: secondHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Color(0xFF4CAF93), width: 2),
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.only(
                  left: 16,
                ),
              ),
              items: TripleInputField.usStates.entries.map((entry) {
                return DropdownMenuItem<String>(
                    value: entry.value, // Abbreviation ("OK")
                    child: Text(
                      entry.key,
                      style: TextStyle(color: Colors.black),
                    ) // Full name ("Oklahoma")
                    );
              }).toList(),
              // selectedItemBuilder lets us override what the selected item
              // looks like once it's picked. We can show the abbreviation here:
              selectedItemBuilder: (context) {
                return TripleInputField.usStates.entries.map((entry) {
                  return Text(entry.value,
                      style: TextStyle(color: Colors.black)); // "OK"
                }).toList();
              },
              onChanged: (selectedAbbrev) {
                if (selectedAbbrev != null) {
                  // The user picks "Oklahoma" in the menu, but we store "OK".
                  stateController.text = selectedAbbrev;
                }
              },
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(width: spacing),

          // Third field (ZIP code)
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: thirdController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: thirdLabel,
                hintText: thirdHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: Color(0xFF4CAF93), width: 2),
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: thirdValidator,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool hasArrow;
  final VoidCallback? onTap;
  final Widget? trailing;

  const InfoTile({
    super.key,
    required this.label,
    required this.value,
    this.hasArrow = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 165,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (hasArrow)
              const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class SectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry titlePadding;
  final TextStyle titleStyle;
  final Color backgroundColor;
  final double titleSpacing;
  final EdgeInsetsGeometry contentPadding;

  const SectionWidget({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 16),
    this.titleStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    this.backgroundColor = Colors.white,
    this.titleSpacing = 8,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: titlePadding,
            child: Text(title, style: titleStyle),
          ),
          SizedBox(height: titleSpacing),
          Container(
            color: backgroundColor,
            padding: contentPadding,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // Optional: Include the InfoTile builder as a static method
  static Widget buildInfoTile(String label, String? value) {
    return InfoTile(
      label: label,
      value: value ?? 'Not set',
    );
  }
}

String toTitleCase(String? str) {
  if (str == null || str.isEmpty) return '';
  return str.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
