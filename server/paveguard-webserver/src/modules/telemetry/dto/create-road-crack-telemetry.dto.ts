import { Field, ArgsType } from '@nestjs/graphql';
import { IsInt, IsNotEmpty, Max, Min } from 'class-validator';
import { CreateDynamicTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateRoadCrackTelemetryDto extends CreateDynamicTelemetryDto {
  @Field()
  @IsInt()
  @Min(0)
  @Max(100)
  @IsNotEmpty()
  severity: number;
}