import 'package:bookedin_app/core/constants.dart';
import 'package:bookedin_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bookedin_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
// import '../../features/auth/domain/usecases/set_password_usecase.dart';
// import '../../features/auth/domain/usecases/get_me_usecase.dart';

final sl = GetIt.instance;

void init() {
  // Core
  sl.registerLazySingleton(
    () => DioClient(
      baseUrl: baseUrl,
    ),
  );

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), dioClient: sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  // sl.registerLazySingleton(() => SetPasswordUseCase(sl()));
  // sl.registerLazySingleton(() => GetMeUseCase(sl()));

  // Cubit
  sl.registerFactory(() => AuthCubit(loginUseCase: sl()));
}
