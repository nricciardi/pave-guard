import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';



@Schema({ 
  discriminatorKey: 'type',
  timeseries: {
    timeField: "timestamp",
    granularity: "seconds"
  } 
})
export class Telemetry extends Document {

  @Prop({ required: true })
  timestamp: Date;

  @Prop({ required: true })
  latitude: number;

  @Prop({ required: true })
  longitude: number;

  @Prop({ type: Types.ObjectId, ref: 'Device', required: true })
  deviceId: Types.ObjectId;
}

export const TelemetrySchema = SchemaFactory.createForClass(Telemetry);
