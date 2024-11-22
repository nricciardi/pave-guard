import { Field, ArgsType } from '@nestjs/graphql';
import { IsNumber, IsString } from 'class-validator';
import { CreateTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateFailTelemetryDto extends CreateTelemetryDto {
  @Field()
  @IsString()
  code: string;

  @Field()
  @IsString()
  message: string;
}