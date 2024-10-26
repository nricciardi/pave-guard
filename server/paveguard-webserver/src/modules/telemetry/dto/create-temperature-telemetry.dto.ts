import { InputType, Field } from '@nestjs/graphql';
import { IsNumber } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@InputType()
export class CreateTemperatureTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsNumber()
  temperature: number;
}