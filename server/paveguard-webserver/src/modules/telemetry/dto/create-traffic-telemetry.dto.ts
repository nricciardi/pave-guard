import { Field, ArgsType } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateTrafficTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  start: number;

  @Field()
  @IsNumber()
  @IsNotEmpty()
  end: number;

  @Field({
    nullable: true
  })
  @IsNumber()
  level?: number;
}