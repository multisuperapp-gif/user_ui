part of '../../main.dart';

class _AddressesPage extends StatefulWidget {
  const _AddressesPage();

  @override
  State<_AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<_AddressesPage> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<_UserAddressData> _addresses = const <_UserAddressData>[];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final addresses = await _UserAppApi.fetchAddresses();
      if (!mounted) {
        return;
      }
      setState(() {
        _addresses = addresses;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _openEditor({_UserAddressData? existing}) async {
    final input = await showModalBottomSheet<_UserAddressInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressEditorSheet(existing: existing),
    );
    if (input == null) {
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      if (existing == null) {
        await _UserAppApi.createAddress(input);
      } else {
        await _UserAppApi.updateAddress(existing.id, input);
      }
      await _loadAddresses();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _setDefault(_UserAddressData address) async {
    setState(() {
      _saving = true;
    });
    try {
      await _UserAppApi.setDefaultAddress(address.id);
      await _loadAddresses();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _delete(_UserAddressData address) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete address?'),
            content: Text('Remove ${address.label} from your saved addresses?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Keep'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      await _UserAppApi.deleteAddress(address.id);
      await _loadAddresses();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : () => _openEditor(),
        backgroundColor: const Color(0xFFCB6E5B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add address'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Saved addresses',
                      style: TextStyle(
                        color: Color(0xFF22314D),
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'Set the default address here. Checkout, labour, and service bookings will use the saved location tied to each address.',
                style: TextStyle(
                  color: const Color(0xFF22314D).withValues(alpha: 0.68),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_off_rounded, size: 42, color: Color(0xFFCB6E5B)),
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF5A6477),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: _loadAddresses,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _addresses.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_searching_rounded, size: 48, color: Color(0xFFCB6E5B)),
                                    SizedBox(height: 12),
                                    Text(
                                      'No saved addresses yet',
                                      style: TextStyle(
                                        color: Color(0xFF22314D),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Add one address now so orders and bookings can use a real delivery location.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF6E7B91),
                                        fontWeight: FontWeight.w600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 96),
                              itemCount: _addresses.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final address = _addresses[index];
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 18,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: address.isDefault ? const Color(0xFFCB6E5B) : const Color(0xFFF0ECE7),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              address.isDefault ? '${address.label} · Default' : address.label,
                                              style: TextStyle(
                                                color: address.isDefault ? Colors.white : const Color(0xFF22314D),
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: _saving ? null : () => _openEditor(existing: address),
                                            icon: const Icon(Icons.edit_rounded),
                                            color: const Color(0xFF22314D),
                                          ),
                                          IconButton(
                                            onPressed: _saving ? null : () => _delete(address),
                                            icon: const Icon(Icons.delete_outline_rounded),
                                            color: const Color(0xFFB94F4F),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        address.fullAddress,
                                        style: const TextStyle(
                                          color: Color(0xFF22314D),
                                          fontWeight: FontWeight.w800,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${address.city}, ${address.state} · ${address.postalCode}',
                                        style: const TextStyle(
                                          color: Color(0xFF6E7B91),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (address.landmark.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Landmark: ${address.landmark}',
                                          style: const TextStyle(
                                            color: Color(0xFF8B756A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Text(
                                        'Lat ${address.latitudeLabel} · Lng ${address.longitudeLabel}',
                                        style: const TextStyle(
                                          color: Color(0xFF9A8E84),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (!address.isDefault) ...[
                                        const SizedBox(height: 12),
                                        OutlinedButton.icon(
                                          onPressed: _saving ? null : () => _setDefault(address),
                                          icon: const Icon(Icons.check_circle_outline_rounded),
                                          label: const Text('Set as default'),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressEditorSheet extends StatefulWidget {
  const _AddressEditorSheet({this.existing});

  final _UserAddressData? existing;

  @override
  State<_AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<_AddressEditorSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isDefault = false;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedMapLabel;
  bool _loadingLocationMasters = true;
  String? _locationMasterError;
  List<_ServiceCountryOption> _countries = const <_ServiceCountryOption>[];
  List<_ServiceStateOption> _states = const <_ServiceStateOption>[];
  _ServiceCountryOption? _selectedCountry;
  _ServiceStateOption? _selectedState;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _labelController = TextEditingController(text: existing?.label ?? '');
    _line1Controller = TextEditingController(text: existing?.addressLine1 ?? '');
    _line2Controller = TextEditingController(text: existing?.addressLine2 ?? '');
    _landmarkController = TextEditingController(text: existing?.landmark ?? '');
    _cityController = TextEditingController(text: existing?.city ?? '');
    _stateController = TextEditingController(text: existing?.state ?? '');
    _countryController = TextEditingController(text: existing?.country.isNotEmpty == true ? existing!.country : 'India');
    _postalController = TextEditingController(text: existing?.postalCode ?? '');
    _isDefault = existing?.isDefault ?? false;
    _selectedLatitude = existing?.latitude;
    _selectedLongitude = existing?.longitude;
    _selectedMapLabel = existing?.fullAddress;
    unawaited(_loadLocationMasters());
  }

  @override
  void dispose() {
    _labelController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationMasters() async {
    setState(() {
      _loadingLocationMasters = true;
      _locationMasterError = null;
    });
    try {
      final countries = await _UserAppApi.fetchServiceCountries();
      if (!mounted) {
        return;
      }
      _countries = countries;
      final existing = widget.existing;
      final fallbackCountry = countries.firstWhere(
        (entry) => entry.name.toLowerCase() == 'india',
        orElse: () => countries.isNotEmpty ? countries.first : const _ServiceCountryOption(id: 0, name: ''),
      );
      _selectedCountry = _resolveCountry(
            id: existing?.countryId,
            name: existing?.country,
          ) ??
          (fallbackCountry.id > 0 ? fallbackCountry : null);
      _countryController.text = _selectedCountry?.name ?? '';
      await _loadStatesForCountry(
        _selectedCountry?.id,
        desiredStateId: existing?.stateId,
        desiredStateName: existing?.state,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingLocationMasters = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationMasterError = '$error'.replaceFirst('Exception: ', '');
        _loadingLocationMasters = false;
      });
    }
  }

  Future<void> _loadStatesForCountry(
    int? countryId, {
    int? desiredStateId,
    String? desiredStateName,
  }) async {
    if (countryId == null || countryId <= 0) {
      if (!mounted) {
        return;
      }
      setState(() {
        _states = const <_ServiceStateOption>[];
        _selectedState = null;
      });
      return;
    }
    final states = await _UserAppApi.fetchServiceStates(countryId: countryId);
    if (!mounted) {
      return;
    }
    setState(() {
      _states = states;
      _selectedState = _resolveState(
        list: states,
        id: desiredStateId,
        name: desiredStateName,
      );
    });
    _stateController.text = _selectedState?.name ?? '';
  }

  _ServiceCountryOption? _resolveCountry({int? id, String? name}) {
    for (final country in _countries) {
      if (id != null && country.id == id) {
        return country;
      }
      if (name != null && country.name.toLowerCase() == name.trim().toLowerCase()) {
        return country;
      }
    }
    return null;
  }

  _ServiceStateOption? _resolveState({
    required List<_ServiceStateOption> list,
    int? id,
    String? name,
  }) {
    for (final state in list) {
      if (id != null && state.id == id) {
        return state;
      }
      if (name != null && state.name.toLowerCase() == name.trim().toLowerCase()) {
        return state;
      }
    }
    return null;
  }

  Future<void> _selectCountry() async {
    if (_countries.isEmpty) {
      return;
    }
    final selected = await _showLocationOptionSheet<_ServiceCountryOption>(
      context,
      title: 'Select country',
      items: _countries,
      selectedValue: _selectedCountry,
      itemLabel: (entry) => entry.name,
    );
    if (selected == null || !mounted) {
      return;
    }
    if (_selectedCountry?.id == selected.id) {
      return;
    }
    setState(() {
      _selectedCountry = selected;
      _selectedState = null;
      _states = const <_ServiceStateOption>[];
      _locationMasterError = null;
    });
    _countryController.text = selected.name;
    _stateController.clear();
    try {
      await _loadStatesForCountry(selected.id);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationMasterError = '$error'.replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _selectState() async {
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select country first.')),
      );
      return;
    }
    if (_states.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No states were loaded for the selected country yet.')),
      );
      return;
    }
    final selected = await _showLocationOptionSheet<_ServiceStateOption>(
      context,
      title: 'Select state',
      items: _states,
      selectedValue: _selectedState,
      itemLabel: (entry) => entry.name,
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _selectedState = selected;
    });
    _stateController.text = selected.name;
  }

  Future<void> _searchState() async {
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select country first.')),
      );
      return;
    }
    if (_states.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No states are loaded to search yet.')),
      );
      return;
    }
    final selected = await showSearch<_ServiceStateOption?>(
      context: context,
      delegate: _StateSearchDelegate(
        states: _states,
        initialSelection: _selectedState,
      ),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _selectedState = selected;
    });
    _stateController.text = selected.name;
  }

  Future<void> _syncSelectionsFromNames({
    String? countryName,
    String? stateName,
  }) async {
    final resolvedCountry = _resolveCountry(name: countryName);
    if (resolvedCountry == null) {
      return;
    }
    final countryChanged = _selectedCountry?.id != resolvedCountry.id;
    setState(() {
      _selectedCountry = resolvedCountry;
      if (countryChanged) {
        _selectedState = null;
        _states = const <_ServiceStateOption>[];
      }
    });
    _countryController.text = resolvedCountry.name;
    if (countryChanged) {
      _stateController.clear();
    }
    await _loadStatesForCountry(
      resolvedCountry.id,
      desiredStateName: stateName,
    );
  }

  Future<void> _pickFromMap() async {
    final selected = await _openUserAddressMapPicker(
      context,
      title: widget.existing == null ? 'Pick address location' : 'Update address location',
      accentColor: const Color(0xFFCB6E5B),
      subtitle: 'Move the pin to the exact delivery point for this address.',
      initialLatitude: _selectedLatitude,
      initialLongitude: _selectedLongitude,
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _selectedLatitude = selected.latitude;
      _selectedLongitude = selected.longitude;
      _selectedMapLabel = selected.addressLabel;
    });
    if (selected.addressLine1?.isNotEmpty == true) {
      _line1Controller.text = selected.addressLine1!;
    }
    if (selected.landmark?.isNotEmpty == true && _landmarkController.text.trim().isEmpty) {
      _landmarkController.text = selected.landmark!;
    }
    if (selected.city?.isNotEmpty == true) {
      _cityController.text = selected.city!;
    }
    unawaited(
      _syncSelectionsFromNames(
        countryName: selected.country,
        stateName: selected.state,
      ),
    );
    if (selected.postalCode?.isNotEmpty == true) {
      _postalController.text = selected.postalCode!;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedLatitude == null || _selectedLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select the address location from the map first.')),
      );
      return;
    }
    Navigator.of(context).pop(
      _UserAddressInput(
        label: _labelController.text.trim(),
        addressLine1: _line1Controller.text.trim(),
        addressLine2: _line2Controller.text.trim(),
        landmark: _landmarkController.text.trim(),
        city: _cityController.text.trim(),
        stateId: _selectedState?.id,
        state: _selectedState?.name.trim() ?? '',
        countryId: _selectedCountry?.id,
        country: _selectedCountry?.name.trim() ?? '',
        postalCode: _postalController.text.trim(),
        latitude: _selectedLatitude!,
        longitude: _selectedLongitude!,
        isDefault: _isDefault,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final topInset = MediaQuery.sizeOf(context).height * 0.03;
    return Padding(
      padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F2EC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.existing == null ? 'Add address' : 'Edit address',
                        style: const TextStyle(
                          color: Color(0xFF22314D),
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: const Color(0xFF22314D),
                          tooltip: 'Cancel',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pick the address from the map. We’ll save the exact latitude and longitude automatically for delivery and booking.',
                    style: TextStyle(
                      color: Color(0xFF6E7B91),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _AddressInputField(controller: _labelController, label: 'Label', validator: _requiredField),
                  _AddressInputField(controller: _line1Controller, label: 'Address line 1', validator: _requiredField),
                  _AddressInputField(controller: _line2Controller, label: 'Address line 2 (optional)'),
                  _AddressInputField(controller: _landmarkController, label: 'Landmark (optional)'),
                  Row(
                    children: [
                      Expanded(
                        child: _AddressInputField(controller: _cityController, label: 'City', validator: _requiredField),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SelectableAddressField(
                          label: 'Country',
                          controller: _countryController,
                          hint: _loadingLocationMasters ? 'Loading countries...' : 'Select country',
                          validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                          onTap: _loadingLocationMasters ? null : _selectCountry,
                          enabled: !_loadingLocationMasters,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _SelectableAddressField(
                          label: 'State',
                          controller: _stateController,
                          hint: _selectedCountry == null
                              ? 'Select country first'
                              : _loadingLocationMasters
                                  ? 'Loading states...'
                                  : 'Select state',
                          validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                          onTap: _loadingLocationMasters ? null : _selectState,
                          enabled: !_loadingLocationMasters,
                          trailing: IconButton(
                            onPressed: _loadingLocationMasters ? null : _searchState,
                            icon: const Icon(Icons.search_rounded),
                            tooltip: 'Search state',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AddressInputField(
                          controller: _postalController,
                          label: 'Postal code',
                          keyboardType: TextInputType.number,
                          validator: _requiredField,
                        ),
                      ),
                    ],
                  ),
                  if (_locationMasterError != null) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3EE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFD5C7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFCB6E5B)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _locationMasterError!,
                              style: const TextStyle(
                                color: Color(0xFF8A4B40),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadLocationMasters,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pinned location',
                          style: TextStyle(
                            color: Color(0xFF22314D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedMapLabel ?? 'No map pin selected yet.',
                          style: TextStyle(
                            color: _selectedLatitude != null && _selectedLongitude != null
                                ? const Color(0xFF5A6477)
                                : const Color(0xFFB94F4F),
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        if (_selectedLatitude != null && _selectedLongitude != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Lat ${_formatMapCoordinate(_selectedLatitude!)} · Lng ${_formatMapCoordinate(_selectedLongitude!)}',
                            style: const TextStyle(
                              color: Color(0xFF9A8E84),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _pickFromMap,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFCB6E5B),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.map_outlined),
                            label: Text(
                              _selectedLatitude == null || _selectedLongitude == null
                                  ? 'Select from map'
                                  : 'Update map pin',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    value: _isDefault,
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: const Color(0xFFCB6E5B),
                    title: const Text(
                      'Use as default address',
                      style: TextStyle(
                        color: Color(0xFF22314D),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onChanged: (value) => setState(() {
                      _isDefault = value;
                    }),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFCB6E5B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: Text(widget.existing == null ? 'Save address' : 'Update address'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

}

class _AddressInputField extends StatelessWidget {
  const _AddressInputField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        scrollPadding: const EdgeInsets.only(bottom: 220),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SelectableAddressField extends StatelessWidget {
  const _SelectableAddressField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onTap,
    required this.enabled,
    this.validator,
    this.trailing,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback? onTap;
  final bool enabled;
  final String? Function(String?)? validator;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: enabled ? onTap : null,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: enabled ? Colors.white : const Color(0xFFF0ECE7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          suffixIcon: trailing ??
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF22314D),
              ),
        ),
      ),
    );
  }
}

Future<T?> _showLocationOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required String Function(T item) itemLabel,
  T? selectedValue,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F2EC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = selectedValue == item;
                  return Material(
                    color: selected ? const Color(0xFFFFE7DF) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      title: Text(
                        itemLabel(item),
                        style: const TextStyle(
                          color: Color(0xFF22314D),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFFCB6E5B))
                          : null,
                      onTap: () => Navigator.of(context).pop(item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StateSearchDelegate extends SearchDelegate<_ServiceStateOption?> {
  _StateSearchDelegate({
    required List<_ServiceStateOption> states,
    this.initialSelection,
  }) : _states = List<_ServiceStateOption>.from(states);

  final List<_ServiceStateOption> _states;
  final _ServiceStateOption? initialSelection;

  @override
  String get searchFieldLabel => 'Search state';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.close_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = normalizedQuery.isEmpty
        ? _states
        : _states.where((entry) => entry.name.toLowerCase().contains(normalizedQuery)).toList(growable: false);
    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'No matching state found.',
          style: TextStyle(
            color: Color(0xFF6E7B91),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = filtered[index];
        final selected = initialSelection?.id == item.id;
        return Material(
          color: selected ? const Color(0xFFFFE7DF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(
              item.name,
              style: const TextStyle(
                color: Color(0xFF22314D),
                fontWeight: FontWeight.w800,
              ),
            ),
            trailing: selected
                ? const Icon(Icons.check_circle_rounded, color: Color(0xFFCB6E5B))
                : null,
            onTap: () => close(context, item),
          ),
        );
      },
    );
  }
}

class _AddressMapSelection {
  const _AddressMapSelection({
    required this.latitude,
    required this.longitude,
    this.addressLabel,
    this.addressLine1,
    this.landmark,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  final double latitude;
  final double longitude;
  final String? addressLabel;
  final String? addressLine1;
  final String? landmark;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
}

Future<_AddressMapSelection?> _openUserAddressMapPicker(
  BuildContext context, {
  required String title,
  required Color accentColor,
  String? subtitle,
  double? initialLatitude,
  double? initialLongitude,
}) {
  return Navigator.of(context).push<_AddressMapSelection>(
    MaterialPageRoute(
      builder: (_) => _UserAddressMapPickerPage(
        title: title,
        accentColor: accentColor,
        subtitle: subtitle,
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
      fullscreenDialog: true,
    ),
  );
}

class _UserAddressMapPickerPage extends StatefulWidget {
  const _UserAddressMapPickerPage({
    required this.title,
    required this.accentColor,
    this.subtitle,
    this.initialLatitude,
    this.initialLongitude,
  });

  final String title;
  final Color accentColor;
  final String? subtitle;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<_UserAddressMapPickerPage> createState() => _UserAddressMapPickerPageState();
}

class _UserAddressMapPickerPageState extends State<_UserAddressMapPickerPage> {
  late LatLng _selectedPosition;
  GoogleMapController? _mapController;
  bool _isResolvingCurrentLocation = false;
  bool _isResolvingAddress = false;
  String? _locationHint;
  Placemark? _selectedPlacemark;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedPosition = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    } else {
      _selectedPosition = LatLng(
        double.parse(_defaultMapLatitude),
        double.parse(_defaultMapLongitude),
      );
    }
    unawaited(_resolveSelectedAddress());
    unawaited(_loadCurrentLocation());
  }

  void _setSelectedPosition(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _selectedPlacemark = null;
    });
    unawaited(_moveCamera(position));
    unawaited(_resolveSelectedAddress());
  }

  Future<void> _moveCamera(LatLng position) async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 16,
        ),
      ),
    );
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isResolvingCurrentLocation = true;
      _locationHint = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location is turned off. You can still place the pin manually on the map.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is not enabled. You can still place the pin manually on the map.');
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) {
        return;
      }
      final livePosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPosition = livePosition;
        _selectedPlacemark = null;
        _isResolvingCurrentLocation = false;
      });
      await _moveCamera(livePosition);
      unawaited(_resolveSelectedAddress());
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isResolvingCurrentLocation = false;
        _locationHint = '$error'.replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _resolveSelectedAddress() async {
    setState(() {
      _isResolvingAddress = true;
    });
    try {
      final placemarks = await placemarkFromCoordinates(
        _selectedPosition.latitude,
        _selectedPosition.longitude,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedPlacemark = placemarks.isEmpty ? null : placemarks.first;
        _isResolvingAddress = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedPlacemark = null;
        _isResolvingAddress = false;
      });
    }
  }

  String? get _addressLabel {
    final placemark = _selectedPlacemark;
    if (placemark == null) {
      return null;
    }
    final parts = <String>[
      if ((placemark.name ?? '').trim().isNotEmpty) placemark.name!.trim(),
      if ((placemark.subLocality ?? '').trim().isNotEmpty) placemark.subLocality!.trim(),
      if ((placemark.locality ?? '').trim().isNotEmpty) placemark.locality!.trim(),
      if ((placemark.administrativeArea ?? '').trim().isNotEmpty) placemark.administrativeArea!.trim(),
      if ((placemark.postalCode ?? '').trim().isNotEmpty) placemark.postalCode!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  String? get _addressLine1 {
    final placemark = _selectedPlacemark;
    if (placemark == null) {
      return null;
    }
    final parts = <String>[
      if ((placemark.name ?? '').trim().isNotEmpty) placemark.name!.trim(),
      if ((placemark.thoroughfare ?? '').trim().isNotEmpty) placemark.thoroughfare!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2EC),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF22314D),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: widget.accentColor.withValues(alpha: 0.20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subtitle ?? 'Tap the map or drag the pin to the exact delivery spot.',
                      style: const TextStyle(
                        color: Color(0xFF22314D),
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _addressLabel ??
                          'Lat ${_formatMapCoordinate(_selectedPosition.latitude)} · Lng ${_formatMapCoordinate(_selectedPosition.longitude)}',
                      style: TextStyle(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_isResolvingAddress) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Finding address details...',
                        style: TextStyle(
                          color: Color(0xFF6E7B91),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (_isResolvingCurrentLocation) ...[
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Finding your current location...',
                              style: TextStyle(
                                color: Color(0xFF6E7B91),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_locationHint != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _locationHint!,
                        style: const TextStyle(
                          color: Color(0xFFB94F4F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      unawaited(_moveCamera(_selectedPosition));
                    },
                    initialCameraPosition: CameraPosition(
                      target: _selectedPosition,
                      zoom: 16,
                    ),
                    mapType: MapType.normal,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onTap: _setSelectedPosition,
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected-address'),
                        position: _selectedPosition,
                        draggable: true,
                        onDragEnd: _setSelectedPosition,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
                      ),
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _AddressMapSelection(
                        latitude: _selectedPosition.latitude,
                        longitude: _selectedPosition.longitude,
                        addressLabel: _addressLabel,
                        addressLine1: _addressLine1,
                        landmark: _selectedPlacemark?.subLocality?.trim(),
                        city: (_selectedPlacemark?.locality ?? _selectedPlacemark?.subAdministrativeArea ?? '').trim(),
                        state: _selectedPlacemark?.administrativeArea?.trim(),
                        country: _selectedPlacemark?.country?.trim(),
                        postalCode: _selectedPlacemark?.postalCode?.trim(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Use this location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
