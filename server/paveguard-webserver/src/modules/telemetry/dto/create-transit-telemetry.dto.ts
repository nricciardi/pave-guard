import { Field, ArgsType } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber, Min } from 'class-validator';
import { CreateStaticTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateTransitTelemetryDto extends CreateStaticTelemetryDto {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  @Min(0)
  length: number;

  @Field()
  @IsNumber()
  @IsNotEmpty()
  @Min(0)
  velocity: number;

  @Field()
  @IsNumber()
  @IsNotEmpty()
  @Min(0)
  transitTime: number;
}