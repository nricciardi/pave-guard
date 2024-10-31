import { Field, ArgsType } from '@nestjs/graphql';
import { IsNumber } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateTrafficTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsNumber()
  start: number;

  @Field()
  @IsNumber()
  end: number;

  @Field({
    nullable: true
  })
  @IsNumber()
  level?: number;
}