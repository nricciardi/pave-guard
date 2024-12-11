import { Field, ArgsType } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber, Max, Min } from 'class-validator';
import { CreateStaticTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateHumidityTelemetryDto extends CreateStaticTelemetryDto {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  @Min(0)
  @Max(100)
  humidity: number;
}