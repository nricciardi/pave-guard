import { Field, ID, ObjectType } from '@nestjs/graphql';
import { ITelemetryQuery, ITelemetrySchema, Telemetry } from './telemetry.model';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';


@ObjectType()
export class HumidityTelemetryQuery implements ITelemetryQuery {

  @Field(() => ID)
  id: string;

  @Field()
  deviceId: string;

  @Field()
  timestamp: number;

  @Field()
  humidity: number;
}


@Schema()
export class HumidityTelemetry implements ITelemetrySchema {
  kind: string;
  deviceId: string;
  timestamp: number;

  @Prop({ required: true })
  humidity: number;
}

export const HumidityTelemetrySchema = SchemaFactory.createForClass(HumidityTelemetry);
