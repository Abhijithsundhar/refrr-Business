import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/Core/constants/failure.dart';

typedef FutureEither<T> = Future<Either<Failure,T>>;
typedef FutureVoid = Future<Either<Failure,void>>;