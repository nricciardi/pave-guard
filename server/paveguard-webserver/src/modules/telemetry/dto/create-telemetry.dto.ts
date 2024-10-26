// src/telemetry/dto/create-telemetry.dto.ts
import { InputType, Field } from '@nestjs/graphql';
import { IsDate, IsString } from 'class-validator';

@InputType()
export class CreateTelemetryDto {
  @Field()
  @IsString()
  deviceId: string;

  @Field()
  @IsDate()
  timestamp: Date;
}
