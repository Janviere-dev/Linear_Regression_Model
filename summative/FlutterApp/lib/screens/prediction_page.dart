import 'package:flutter/material.dart';
import '../models/delivery_request.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/error_card.dart';
import '../widgets/numeric_field_card.dart';
import '../widgets/pill_selector_card.dart';
import '../widgets/result_card.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _ageController = TextEditingController();
  final _ratingController = TextEditingController();
  final _restLatController = TextEditingController();
  final _restLonController = TextEditingController();
  final _delLatController = TextEditingController();
  final _delLonController = TextEditingController();

  String? _selectedOrderType;
  String? _selectedVehicleType;

  bool _isLoading = false;
  double? _result;
  String? _errorMessage;

  static const _orderOptions = ['Snack', 'Drinks', 'Buffet', 'Meal'];
  static const _vehicleOptions = ['motorcycle', 'scooter', 'electric_scooter', 'bicycle'];
  static const _vehicleLabels = ['Motorcycle', 'Scooter', 'E-Scooter', 'Bicycle'];

  @override
  void dispose() {
    _ageController.dispose();
    _ratingController.dispose();
    _restLatController.dispose();
    _restLonController.dispose();
    _delLatController.dispose();
    _delLonController.dispose();
    super.dispose();
  }

  Future<void> _onPredictPressed() async {
    setState(() {
      _result = null;
      _errorMessage = null;
    });

    final age = int.tryParse(_ageController.text);
    final rating = double.tryParse(_ratingController.text);
    final restLat = double.tryParse(_restLatController.text);
    final restLon = double.tryParse(_restLonController.text);
    final delLat = double.tryParse(_delLatController.text);
    final delLon = double.tryParse(_delLonController.text);

    if (age == null ||
        rating == null ||
        restLat == null ||
        restLon == null ||
        delLat == null ||
        delLon == null ||
        _selectedOrderType == null ||
        _selectedVehicleType == null) {
      setState(() {
        _errorMessage = 'Please fill in every field before predicting.';
      });
      return;
    }

    setState(() => _isLoading = true);

    final request = DeliveryRequest(
      age: age,
      rating: rating,
      restaurantLat: restLat,
      restaurantLon: restLon,
      deliveryLat: delLat,
      deliveryLon: delLon,
      typeOfOrder: _selectedOrderType!,
      typeOfVehicle: _selectedVehicleType!,
    );

    try {
      final prediction = await ApiService.predictDeliveryTime(request);
      setState(() => _result = prediction);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Could not reach the server. Check your connection.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery Time Predictor',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Fill in the delivery details to estimate arrival time.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              NumericFieldCard(
                title: 'Courier Age',
                subtitle: 'Age in years (15-50)',
                hint: 'e.g. 30',
                controller: _ageController,
                allowDecimal: false,
              ),
              NumericFieldCard(
                title: 'Courier Rating',
                subtitle: 'Average rating (1.0-5.0)',
                hint: 'e.g. 4.7',
                controller: _ratingController,
              ),
              NumericFieldCard(
                title: 'Restaurant Latitude',
                subtitle: 'Pickup location latitude',
                hint: 'e.g. 12.9716',
                controller: _restLatController,
              ),
              NumericFieldCard(
                title: 'Restaurant Longitude',
                subtitle: 'Pickup location longitude',
                hint: 'e.g. 77.5946',
                controller: _restLonController,
              ),
              NumericFieldCard(
                title: 'Delivery Latitude',
                subtitle: 'Drop-off location latitude',
                hint: 'e.g. 13.0350',
                controller: _delLatController,
              ),
              NumericFieldCard(
                title: 'Delivery Longitude',
                subtitle: 'Drop-off location longitude',
                hint: 'e.g. 77.6431',
                controller: _delLonController,
              ),
              PillSelectorCard(
                title: 'Type of Order',
                subtitle: 'What was ordered',
                options: _orderOptions,
                labels: _orderOptions,
                selected: _selectedOrderType,
                onSelected: (v) => setState(() => _selectedOrderType = v),
              ),
              PillSelectorCard(
                title: 'Type of Vehicle',
                subtitle: "Courier's vehicle",
                options: _vehicleOptions,
                labels: _vehicleLabels,
                selected: _selectedVehicleType,
                onSelected: (v) => setState(() => _selectedVehicleType = v),
              ),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _isLoading ? null : _onPredictPressed,
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Predict',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              if (_result != null) ResultCard(minutes: _result!),
              if (_errorMessage != null) ErrorCard(message: _errorMessage!),
            ],
          ),
        ),
      ),
    );
  }
}
