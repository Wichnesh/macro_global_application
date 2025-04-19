import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/map/MapBloc.dart';
import '../blocs/map/MapEvent.dart';
import '../blocs/map/MapState.dart';
import 'project_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;

  static const LatLng _defaultCenter = LatLng(11.1271, 78.6569); // Tamil Nadu center

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(LoadMapProjects());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Map")),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MapLoaded) {
            final Set<Marker> markers = state.projects
                .where((p) => p.latitude != null && p.longitude != null)
                .map((p) => Marker(
                      markerId: MarkerId(p.id),
                      position: LatLng(p.latitude!, p.longitude!),
                      infoWindow: InfoWindow(
                        title: p.name,
                        snippet: '👥 ${p.peopleWorking} People',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(p),
                            ),
                          );
                        },
                      ),
                    ))
                .toSet();

            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _defaultCenter,
                zoom: 7,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: markers,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
            );
          } else if (state is MapError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
