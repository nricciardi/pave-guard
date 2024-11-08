import { Resolver, Query, Field, ID, ObjectType } from '@nestjs/graphql';
import { TelemetryService } from '../services/telemetry/telemetry.service';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';

@ObjectType()
export class TelemetryQuery {
  @Field(() => ID)
  id: string;

  @Field()
  deviceId: string;

  @Field()
  timestamp: Date;

  @Field()
  latitude: number;

  @Field()
  longitude: number;
}

@Resolver(() => TelemetryQuery)
export class TelemetryResolver {
  constructor(
    private readonly telemetryService: TelemetryService,
  ) {}

  @Query(() => [TelemetryQuery])
  @UseGuards(AdminGuard)
  async telemetries() {
    return this.telemetryService.findAll();
  }
}
