import { Field, ArgsType } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateHumidityTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  humidity: number;
}