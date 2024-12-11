import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsMongoId, IsNotEmpty, IsString } from 'class-validator';
import { CreateStaticTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateFailTelemetryDto extends CreateStaticTelemetryDto {
  @Field()
  @IsString()
  @IsMongoId()
  @IsNotEmpty()
  deviceId: string;

  @Field()
  @IsDate()
  @IsNotEmpty()
  timestamp: string;

  @Field()
  @IsString()
  @IsNotEmpty()
  code: string;

  @Field()
  @IsString()
  @IsNotEmpty()
  message: string;
}