import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { CreateTemperatureTelemetryDto } from '../dto/create-temperature-telemetry.dto';
import { TemperatureTelemetryService } from '../services/temperature-telemetry/temperature-telemetry.service';
import { TelemetryQuery } from './telemetry.resolver';
import { JwtAuthenticationGuard } from 'src/modules/user/guards/jwt-authentication/jwt-authentication.guard';
import { UseGuards } from '@nestjs/common';
import { AdminGuard } from 'src/modules/user/guards/admin/admin.guard';
import { TrafficTelemetryService } from '../services/traffic-telemetry/traffic-telemetry.service';
import { CreateTrafficTelemetryDto } from '../dto/create-traffic-telemetry.dto';


@ObjectType()
export class TrafficTelemetryQuery extends TelemetryQuery {

  @Field()
  temperature: number;
}


@Resolver(() => TrafficTelemetryQuery)
export class TrafficTelemetryResolver {
  constructor(
    private readonly trafficTelemetryService: TrafficTelemetryService,
  ) {}

  @Query(() => [TrafficTelemetryQuery])
  @UseGuards(AdminGuard)
  async trafficTelemetries() {
    return this.trafficTelemetryService.findAll();
  }

  @Mutation(() => TrafficTelemetryQuery)
  @UseGuards(JwtAuthenticationGuard)
  async createTrafficTelemetry(
    @Args() input: CreateTrafficTelemetryDto,
  ) {
    return this.trafficTelemetryService.create(input);
  }
}

