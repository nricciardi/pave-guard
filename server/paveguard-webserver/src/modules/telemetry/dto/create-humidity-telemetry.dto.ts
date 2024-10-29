import { Field, ArgsType } from '@nestjs/graphql';
import { IsNumber } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateHumidityTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsNumber()
  humidity: number;
}