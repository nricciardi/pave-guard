import { Field, ArgsType } from '@nestjs/graphql';
import { IsNotEmpty, IsNumber, Max, Min } from 'class-validator';
import { CreateStaticTelemetryDto } from './create-telemetry.dto';

@ArgsType()
export class CreateTemperatureTelemetryDto extends CreateStaticTelemetryDto {
  @Field()
  @IsNumber()
  @IsNotEmpty()
  @Min(-60)
  @Max(60)
  temperature: number;
}