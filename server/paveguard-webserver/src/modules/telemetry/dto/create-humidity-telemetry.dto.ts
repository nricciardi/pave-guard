import { InputType, Field } from '@nestjs/graphql';
import { IsNumber } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@InputType()
export class CreateHumidityTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsNumber()
  humidity: number;
}