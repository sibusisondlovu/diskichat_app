import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/countries_service.dart';
import '../../data/models/country_model.dart';
import '../../utils/themes/app_colors.dart';
import '../../components/common/loading_indicator.dart';

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  final CountriesService _countriesService = CountriesService();
  List<Country> _countries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _countriesService.getActiveCountries();
      setState(() {
        _countries = countries;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load countries: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Select Country'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _countries.length,
              itemBuilder: (context, index) {
                final country = _countries[index];
                return Card(
                  color: AppColors.cardSurface,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: country.flag != null 
                        ? SvgPicture.network(
                            country.flag!,
                            width: 40, 
                            height: 30,
                            placeholderBuilder: (BuildContext context) => const Icon(Icons.flag, color: Colors.grey),
                          )
                        : const Icon(Icons.flag, size: 30, color: Colors.white),
                    title: Text(
                      country.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.accentBlue, size: 16),
                    onTap: () {
                      Navigator.pop(context, country);
                    },
                  ),
                );
              },
            ),
    );
  }
}
