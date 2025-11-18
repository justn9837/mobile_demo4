import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// SupabaseService wraps Supabase client and exposes it as a GetxService.
/// Keep this file small: it only initializes the client and provides a getter.
class SupabaseService extends GetxService {
  late final SupabaseClient client;

  Future<SupabaseService> init() async {
    client = Supabase.instance.client;
    return this;
  }
}
