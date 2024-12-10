import { Field, ArgsType } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber, Min } from 'class-validator';
import { CreateStaticTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateHumidityTelemetryDto extends CreateStaticTelemetryDto {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  @Min(0)
  humidity: number;
}