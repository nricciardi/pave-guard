import { Field, ArgsType } from '@nestjs/graphql';
import { IsDate, IsString } from 'class-validator';

@ArgsType()
export class CreateTelemetryDto {
  @Field()
  @IsString()
  deviceId: string;

  @Field()
  @IsDate()
  timestamp: number;
}
