import { Field, ArgsType } from '@nestjs/graphql';
import { IsNumber } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateTemperatureTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsNumber()
  temperature: number;
}