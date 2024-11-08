import { Field, ArgsType } from '@nestjs/graphql';
import { IsInt, Max, Min } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateRoadCrackTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsInt()
  @Min(0)
  @Max(100)
  severity: number;
}