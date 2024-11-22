import { Field, ArgsType } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateTemperatureTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  temperature: number;
}