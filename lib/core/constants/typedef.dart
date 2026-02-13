import 'package:fpdart/fpdart.dart';
import 'package:refrr_admin/core/constants/failure.dart';

typedef FutureEither<T> = Future<Either<Failure,T>>;
typedef FutureVoid = Future<Either<Failure,void>>;
