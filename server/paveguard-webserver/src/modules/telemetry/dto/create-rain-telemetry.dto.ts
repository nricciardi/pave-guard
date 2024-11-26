import { Field, ArgsType } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber, Min } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateRainTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  @Min(0)
  mm: number;
}