import { Field, ArgsType } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber } from 'class-validator';
import { CreateStaticTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateTemperatureTelemetryDto extends CreateStaticTelemetryDto {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  temperature: number;
}