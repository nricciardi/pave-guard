import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';



@Schema({ 
  discriminatorKey: 'kind',
  timeseries: {
    timeField: "timestamp",
    granularity: "seconds",
    metaField: "metadata"
  } 
})
export class Telemetry extends Document {
  
  kind: string;

  @Prop({
    required: true,
  })
  timestamp: Date;

  @Prop({
    required: true,
    min: -90,
    max: 90,
  })
  latitude: number;

  @Prop({
    required: true,
    min: -180,
    max: 180,
  })
  longitude: number;

  @Prop({
    required: true,
    type: {
      deviceId: { type: Types.ObjectId, ref: 'Device', required: true },
      kind: { type: String, required: false },
      road: { type: String, required: true },
    }
  })
  metadata: {
    deviceId: Types.ObjectId;
    kind: string;
    road: string;
  };
}

export const TelemetrySchema = SchemaFactory.createForClass(Telemetry);

TelemetrySchema.pre('save', function (next) {
  this.metadata.kind = this.kind;
  next();
});